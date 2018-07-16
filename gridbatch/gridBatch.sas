/*----------------------------------------------------------------------------*

   *******************************************************
   *** Copyright 2016, Rho, Inc.  All rights reserved. ***
   *******************************************************

   MACRO:      gridBatch.sas

   PURPOSE:    Submit a SAS job to the Grid in Batch
               - true batch processing using SASGSUB


   ARGUMENTS:  1st =  <fully qualified SAS program file>  REQUIRED
               wait=  <no/yes>
               queue= <normal/priority/night>
               debug= <no/yes>


   DETAILS:    wait=yes,  the macro will wait for the called program to finish
                          before continuing.
                          Use wait=yes for sequential processing.
                          The default (wait=no) processes jobs concurrently.

               queue=,    only use in special circumstances and with permission.
                          The default normal queue should be used for all jobs unless
                          there is a very specific need that is coordinated with IT.
                          Queue names are case sensitive.

               debug=yes, use for debugging purposes by developers or support.
                          Displays all returns from gridBatch on the SAS log of
                          the submitting program.

               *=============================================*
               *  FOR SAS 9.4 or higher ON THE Rho SAS GRID  *
               *=============================================*


   EXAMPLE:    %gridBatch( &ProjDir\Prog\Derive\DM.sas, wait=yes );
               %gridBatch( &ProjDir\Prog\Derive\AE.sas );


   PROGRAM HISTORY:

   DATE        PROGRAMMER        DESCRIPTION
   ---------   ---------------   ----------------------------------------------
   23Jun2016   John Ingersoll    original
   04Sep2016   John Ingersoll    add -work option

*----------------------------------------------------------------------------*/
%macro gridBatch( saspgm
   ,wait=no
   ,queue=normal
   ,debug=no
   );

   %*----------------------------------------------------;
   %* Empty File Spec                                    ;
   %*----------------------------------------------------;
   %if %nrbquote(&saspgm) = %then %do;
      %put ERROR:  Missing required argument to %nrstr(%gridBatch). ;
      %put ERROR:  You must specify a fully qualified SAS program file as the first argument. ;
      %goto ENDMAC;
   %end;


   %*----------------------------------------------------;
   %* Invalid SAS Environment                            ;
   %*----------------------------------------------------;
   %if %symexist(GSCONFIGDIR) = 0 %then %do;
      %put ERROR:  The %nrstr(%gridBatch) macro is not supported in this SAS environment. ;
      %put ERROR:  The %nrstr(&GSCONFIGDIR) macro variable is not defined. ;
      %put ERROR:  This macro was written for use on Rho%str(%')s SAS Grid in version 9.4 or higher. ;
      %goto ENDMAC;
   %end;


   %*----------------------------------------------------;
   %* wait= Argument                                     ;
   %*----------------------------------------------------;
   %let wait = %upcase(&wait);
   %if       %nrbquote(&wait) = NO  %then ;
   %else %if %nrbquote(&wait) = YES %then ;
   %else %do;
      %put ERROR: Invalid WAIT= argument to the %nrstr(%gridBatch) macro. ;
      %put ERROR: It must be YES or NO. ;
      %goto ENDMAC;
   %end;


   %*----------------------------------------------------;
   %* queue= Argument (must be lowercase when passed)    ;
   %*----------------------------------------------------;
   %let queue = %lowcase(&queue);
   %if       %nrbquote(&queue) = normal   %then ;
   %else %if %nrbquote(&queue) = priority %then ;
   %else %if %nrbquote(&queue) = night    %then ;
   %else %do;
      %put ERROR: Invalid QUEUE= argument to the %nrstr(%gridBatch) macro. ;
      %put ERROR: It must be NORMAL, PRIORITY, or NIGHT. ;
      %goto ENDMAC;
   %end;


   %*----------------------------------------------------;
   %* debug= Argument (YES vs. anything else)            ;
   %*----------------------------------------------------;
   %let debug = %upcase(&debug);


   %*----------------------------------------------------;
   %* Remove the Ext from program spec (leaves the dot)  ;
   %*----------------------------------------------------;
   %local Dot sasPgmNoExt;
   %let Dot = %sysfunc( findc(&saspgm,.,-4096) );
   %if &Dot = 0 %then %let sasPgmNoExt = &saspgm.. ;
   %else              %let sasPgmNoExt = %substr( &saspgm, 1, &Dot ) ;


   %*----------------------------------------------------;
   %* Write Notes to the log                             ;
   %*----------------------------------------------------;
   %put;
   %put %sysfunc(repeat(=,99));
   %put NOTE: Submitting &saspgm to the SAS Grid Batch processor ;
   %put NOTE: at %sysfunc(datetime(),datetime.) by &SYSUSERID ;


   %*----------------------------------------------------;
   %* Set SAS Options (save current settings first)      ;
   %*----------------------------------------------------;
   %local optSpool optQuotelenmax optNotes optMlogic optSymbolgen optMprint;
   %let optSpool       = %sysfunc(getoption(SPOOL));
   %let optQuotelenmax = %sysfunc(getoption(QUOTELENMAX));
   %let optNotes       = %sysfunc(getoption(NOTES));
   %let optMlogic      = %sysfunc(getoption(MLOGIC));
   %let optSymbolgen   = %sysfunc(getoption(SYMBOLGEN));
   %let optMprint      = %sysfunc(getoption(MPRINT));
   options SPOOL NOQUOTELENMAX
      %if &debug = YES %then %str(NOTES MPRINT);
      %else                  %str(NONOTES NOMLOGIC NOSYMBOLGEN NOMPRINT);
      ;


   %*----------------------------------------------------------------------;
   %* Submit SASGSUB command and Pipe results to log                       ;
   %* - from example %mygsub provided 18Apr2016 by David Glemaker from SAS ;
   %*----------------------------------------------------------------------;
   %local errFlg gridWaitOpt;
   %if &wait = YES %then %let gridWaitOpt = -GRIDWAIT;

   filename gridRslt pipe "&gsconfigdir\sasgsub.cmd
      -GRIDSUBMITPGM ""&saspgm""
      &gridWaitOpt
      -GRIDJOBOPTS queue=&queue
      -GRIDSASOPTS ""(-work 'F:\SASWORK94' -altlog %str(%')&sasPgmNoExt.log%str(%') -altprint %str(%')&sasPgmNoExt.lst%str(%'))""
      ";
      %* NOTE:  single quotes required around -altlog and -altprint to handle spaces in dir/filenames ;

   data _null_;
      infile gridRslt truncover end=eof;
      length line $200.;
      input line $200.;

      %if &debug = YES %then %do;
         if _N_=1 then putlog '<start pipe>';
      %end;

      %if &debug ^= YES %then %do;
         *--- In normal execution, limit lines written to the log to these ---*;
         if line =: 'Job ID:'
         or line =: 'ERROR:'
         or line =: 'Waiting for grid job'
         or line =: 'Grid job complete'
         ;
      %end;

      *--- When WAIT=YES, append the ending date/time to the message ---*;
      if line =: 'Grid job complete' then line = 'Grid job complete at ' || put(datetime(),datetime.);

      *--- Flag any errors from SASGSUB.  Do not print closing messages when there are errors ---*;
      if line =: 'ERROR:' then do;
         call symput( 'errFlg', 'YES' );
         line = tranwrd( line, 'ERROR:', 'ERROR: ' );          %* add a space after the word error: ;
      end;

      putlog line;

      %if &debug = YES %then %do;
         if eof then putlog '<end pipe>';
      %end;
   run;


   %*----------------------------------------------------;
   %* Reset SAS Options to original settings             ;
   %*----------------------------------------------------;
   options &optSpool &optQuotelenmax &optNotes &optMlogic &optSymbolgen &optMprint;


   %*----------------------------------------------------;
   %* Closing notes                                      ;
   %*----------------------------------------------------;
   %if &errFlg = %then %do;
      %if &wait = NO %then %put NOTE: Not waiting for batch job to complete.  Subsequent jobs will execute concurrently. ;
   %end;

   %put %sysfunc(repeat(=,99));
   %put;


   %ENDMAC:

%mend gridBatch;
