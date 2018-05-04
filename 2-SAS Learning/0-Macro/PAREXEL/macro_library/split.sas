%macro SPLIT (INDAT=,OUTDAT=,OLDCOMS=,NEWLENTH=,NEWCOMS=);

%******************************************************************************;
%*                          PAREXEL INTERNATIONAL LTD                          ;
%*                                                                             ;
%* CLIENT:            PAREXEL                                                  ;
%*                                                                             ;
%* PROJECT:           Macro to split long character variales into smaller      ;
%*                    sections of user-defined length                          ;
%*                                                                             ;
%* TIMS CODE:         68372                                                    ;
%*                                                                             ;
%* SOPS FOLLOWED:     1213                                                     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* PROGRAM NAME:      SPLIT.SAS                                                ;
%*                                                                             ;
%* PROGRAM LOCATION:  /opt/pxlcommon/stats/macros/sas/code/split/ver002        ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* USER REQUIREMENTS: If a text variable is too long to be presented (e.g in an;
%*                     appendix) then the macro should allow this variable to  ;  
%*                     be split into a number of variables of smaller length,  ;
%*                     with the length of these variables defined as a macro   ;
%*                     parameter.                                              ;
%*                                                                             ;
%* TECHNICAL          The macro tries to split the text variable at the chosen ;
%* SPECIFICATIONS:     length.  However, to avoid splitting text mid-word      ;
%*                     the macro will work backwards from this point until it  ;
%*                     finds a space character, and split at this point. This  ;
%*                     process is then repeated untitl the whole text string   ;
%*                     has been similarly split.                               ;
%*                                                                             ;
%* INPUT:             Macro paramters:                                         ;
%*                    INDAT = name of input dataset                            ;
%*                    OUTDAT = name of output dataset                          ;
%*                    OLDCOMS = names of old comment variables (seperate by    ;
%*                              a space), eg. oldcoms = COMMENT1 COMMENT2      ;
%*                    NEWLENTH = required length of each new comment variable  ;
%*                               (NOTE: if you want a maximum length for the   ;
%*                               new variables of N, you should set NEWLENTH   ;
%*                               to be N+1 - otherwise, the macro will split   ;
%*                               before any words anding after exactly N       ;
%*                               characters)                                   ;
%*                    NEWCOMS = names of new comment variables,                ;
%*                              eg. ,newcom = REMARK1-REMARK8                  ;
%*                                                                             ;
%* OUTPUT:            An output dataset with the original OLDCOMS variables    ;
%*                     deleted and replaced with the NEWCOMS variables         ;            
%*                                                                             ;
%* PROGRAMS CALLED:   N/A                                                      ;
%*                                                                             ;
%* ASSUMPTIONS/                                                                ;
%* REFERENCES:        NB Macro will fail if the combined length of the new     ;
%*                    comment variables is less than the combined length of the;
%*                    old comment variables.  Also, because of the way the macro;
%*                    avoids breaking up words, it is often necessary to define;
%*                    slightly longer new variables than would appear necessary,;
%*                    (e.g. four new variables of length 55 for a comment      ;
%*                    variable of length 200).                                 ;                                                          ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* MODIFICATION HISTORY                                                        ;
%*-----------------------------------------------------------------------------;
%* VERSION:           1                                                        ;
%* AUTHOR:            S-Cubed (unknown author)                                 ;
%* QC BY:             N/A                                                      ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           2                                                        ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          High   [X]: System has direct impact on the provision of ;
%*                                business critical services either globally   ;
%*                                or at a regional level.                      ;
%*                    Medium [ ]: System has direct impact on the provision of ;
%*                                business critical services at a local level  ;
%*                                only.                                        ;
%*                    Low    [ ]: System used to indirectly support the        ;
%*                                provision of a business critical service or  ;
%*                                operation at a global, regional or local     ;
%*                                level.                                       ;
%*                    None   [ ]: System has no impact on the provision of a   ;
%*                                business critical service or operation.      ;
%*                                                                             ;
%* Regulatory:        High   [ ]: System has a direct impact on GxP data and/  ;
%*                                or directly supports a GxP process.          ;
%*                    Medium [X]: System has an indirect impact on GxP data    ;
%*                                and supports a GxP process.                  ;
%*                    Low    [ ]: System has an indirect impact on GxP data or ;
%*                                supports a GxP process.                      ;
%*                    None   [ ]: System is not involved directly or           ;
%*                                indirectly with GxP data or a GxP process.   ;
%*                                                                             ;
%* REASON FOR CHANGE: 1) Validation of program to standards required by        ;
%*                       WSOP 1213.                                            ;
%*                    2) Code itself not amended from Version 1                ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output from      ;
%* METHODOLOGY:       SPLIT_VAL.SAS                                            ;
%*                                                                             ;
%* DEVELOPER:         S-Cubed                           Date : Unknown         ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Simon Gillis (Sheffield)          Date : 4 March 2005    ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Simon Gillis (Sheffield)          Date : 4 March 2005    ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;
%* Tested on UNIX platform:-                                                   ;
%*                                                                             ;
%* USER:              Dan Higgins                       Date : 18/07/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;


data &outdat(drop=ncharzz newnozz foundzz poszz startzz oldnozz eostrszz &oldcoms);

  set &INDAT;
  array old[*] $ &oldcoms;
  array new[*] $&newlenth &newcoms;
  newnozz = 0; poszz = 0; oldnozz=1; eostrszz=0;

  do until (eostrszz);
    newnozz+1;
    startzz=poszz+1;
    poszz=poszz+&newlenth;

    if poszz ge length(old[oldnozz]) then do;
      if oldnozz lt dim(old) then do;
        poszz=&newlenth-length(substr(old[oldnozz],startzz));
        IF POSZZ GE 1 THEN DO;
          if substr(old[oldnozz+1],poszz,1) ne ' ' then do until (foundzz);
                poszz = poszz-1;
                IF POSZZ=0 THEN FOUNDZZ=1;
                ELSE if substr(old[oldnozz+1],poszz,1) in(' ') then foundzz=1;
          end;
        END;
        IF POSZZ EQ 0 THEN NEW[NEWNOZZ]=TRIM(SUBSTR(OLD[OLDNOZZ],STARTZZ));
        ELSE new[newnozz]=trim(substr(old[oldnozz],startzz))||' '||substr(old[oldnozz+1],1,poszz);

        oldnozz+1;
      end;
      else do;
        new[newnozz] = substr(old[oldnozz],startzz);
        eostrszz=1;
      end;
    end;

    else do;
      foundzz = 0;
      if substr(old[oldnozz],poszz,1) not in(' ') then do until (foundzz);
        poszz = poszz-1;
        if substr(old[oldnozz],poszz,1) in(' ') then foundzz = 1;
      end;
      foundzz = 0;
      ncharzz = poszz - startzz;
      new[newnozz] = substr(old[oldnozz],startzz,ncharzz);
    end;
  end;
run;

%mend;