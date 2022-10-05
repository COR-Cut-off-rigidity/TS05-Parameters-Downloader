C   THIS CODE MUST BE RUN AFTER THE CODE Fill_IMF_gaps.for  !
c
c   This code goes over the yearly 5-min avg interplanetary data files named YYYY_IMF_gaps_le_3hrs_filled.txt,
c    in which IMF short gaps were filled by the  previously run code Fill_IMF_gaps.for,
c    and fills the gaps in the SW coverage, using the same procedure of linear interpolation.
c    The gaps are filled on condition that they are not too wide (controlled by the upper limit
c    LIMGAP on the number of missing 5-min records).
c
c
c    Author:  N. A. Tsyganenko
c
      DIMENSION VXGSE(105430),VYGSE(105430),VZGSE(105430),TEMP(105430),
     +DEN(105430),BXGSM(105430),BYGSM(105430),BZGSM(105430),
     +IDAY(105430),IHOUR(105430),MIN(105430),IMFFLAG(105430),
     +ISWFLAG(105430), SYMH(105430), VGSE(105430)

      CHARACTER*80 NAMEIN,NAMEOUT
      CHARACTER*256 ARGV

      Call Getarg( 1, ARGV )
      NAMEIN = ARGV

      Call Getarg( 2, ARGV )
      NAMEOUT = ARGV

      DO 111 IYEAR=2022,2022

      DO 11 I=1,105430
 11   ISWFLAG(I)=+1   !  INITIALLY SET AT +1, WHICH MEANS "SW DATA AVAILABLE" FOR ALL 5-MIN INTERVALS

      LIMGAP=900                            !  GAPS LARGER THAN 36*5=180 MIN WILL REMAIN UNFILLED

      OPEN (UNIT=1,FILE=NAMEIN,STATUS='OLD')

C     READ OMNI DATA INTO RAM:

      I=0

 1    READ(1,503,END=2) IYEA,IDA,IHOU,MI,BX,BY,BZ,V,VX,VY,VZ,DE,T,
     *  SYMHIND,IMFLAG
      MINYEAR=(IDA-1)*1440+IHOU*60+MI
      IND=MINYEAR/5+1
      IF (V.EQ.99999.9.OR.VX.EQ.99999.9.OR.VY.EQ.99999.9.OR.VZ.EQ.
     *  99999.9.OR.DE.EQ.999.99.OR.T.EQ.9999999..OR.SYMHIND.GT.999.)
     *ISWFLAG(IND)=-1
C
      IDAY (IND)=IDA
      IHOUR(IND)=IHOU
      MIN  (IND)=MI
      BXGSM(IND)=BX
      BYGSM(IND)=BY
      BZGSM(IND)=BZ
      VGSE(IND)=V
      VXGSE(IND)=VX
      VYGSE(IND)=VY
      VZGSE(IND)=VZ
C      VTH  (IND)=0.15745*SQRT(T)  !  SQRT(3kT/M_p) in km/s   !  DISABLED HERE
      TEMP (IND)=T
      DEN  (IND)=DE
      SYMH(IND)=SYMHIND
      IMFFLAG(IND)=IMFLAG
      I=I+1
      GOTO 1
C
 2    CLOSE(1)
      NREC=I
C
      PRINT *, '  READING OF OMNI DATA FINISHED; NREC=',NREC

 503  FORMAT(2I4,2I3,53X,F8.2,16X,2F8.2,16X,4F8.1,F7.2,F9.0,F6.0,3X,I2)
 505  FORMAT(2I4,2I3,F8.2,2F8.2,4F8.1,F7.2,F9.0,F6.0,3X,I2,3X,I2)
C
C       NOW MAKE THE INTERPOLATION FOR THE INTERNAL GAPS
C
       IFLAG=0    !  INDICATES THAT WE STILL DID NOT GET TO THE FIRST RECORD WITH VALID IMF DATA
C
       DO 21 I=1,NREC
C
          IF (ISWFLAG(I).EQ.-1.AND.IFLAG.EQ.0) GOTO 21
          IFLAG=1   !  GOT TO THE FIRST VALID RECORD
C
        IF (ISWFLAG(I).NE.-1.AND.ISWFLAG(I+1).EQ.-1) THEN  ! FIRST INTERNAL NO-SW-DATA INTERVAL ENCOUNTERED
        IBEG=I
        VBEG=VGSE(IBEG)
        VXBEG=VXGSE(IBEG)
        VYBEG=VYGSE(IBEG)
        VZBEG=VZGSE(IBEG)
        TBEG=TEMP(IBEG)
        DENBEG=DEN(IBEG)
        ENDIF
C
        IF (ISWFLAG(I).EQ.-1.AND.ISWFLAG(I+1).NE.-1) THEN    !  FIRST NORMAL RECORD AFTER THE SW GAP ENCOUNTERED
        IEND=I+1
C
        IF (IEND-IBEG.GT.LIMGAP) GOTO 21
C
        VEND=VGSE(IEND)
        VXEND=VXGSE(IEND)
        VYEND=VYGSE(IEND)
        VZEND=VZGSE(IEND)
        TEND=TEMP(IEND)
        DENEND=DEN(IEND)
C
        DO 22 K=IBEG+1,IEND-1
        A=(VEND-VBEG)/(IEND-IBEG)
        B=(VBEG*IEND-VEND*IBEG)/(IEND-IBEG)
        VGSE(K)=A*K+B
        A=(VXEND-VXBEG)/(IEND-IBEG)              !   LINEAR INTERPOLATION
        B=(VXBEG*IEND-VXEND*IBEG)/(IEND-IBEG)
        VXGSE(K)=A*K+B
        A=(VYEND-VYBEG)/(IEND-IBEG)
        B=(VYBEG*IEND-VYEND*IBEG)/(IEND-IBEG)
        VYGSE(K)=A*K+B
        A=(VZEND-VZBEG)/(IEND-IBEG)
        B=(VZBEG*IEND-VZEND*IBEG)/(IEND-IBEG)
        VZGSE(K)=A*K+B
        A=(TEND-TBEG)/(IEND-IBEG)
        B=(TBEG*IEND-TEND*IBEG)/(IEND-IBEG)
        TEMP(K)=A*K+B
        A=(DENEND-DENBEG)/(IEND-IBEG)
        B=(DENBEG*IEND-DENEND*IBEG)/(IEND-IBEG)
        DEN(K)=A*K+B

        ISWFLAG(K)=2   !   WILL BE WRITTEN INTO THE OUTPUT FILE RECORD, INDICATING THAT THE VALUE WAS
C                            OBTAINED USING THE LINEAR INTERPOLATION
 22     CONTINUE
        ENDIF
C
 21    CONTINUE
C
       OPEN (UNIT=1,FILE=NAMEOUT)
C
       DO 7 I=1,NREC
         WRITE (1,505) IYEA,IDAY(I),IHOUR(I),MIN(I),BXGSM(I),BYGSM(I),
     *   BZGSM(I),VGSE(I),VXGSE(I),VYGSE(I),VZGSE(I),DEN(I),TEMP(I),
     *   SYMH(I),IMFFLAG(I),ISWFLAG(I)
  7    CONTINUE
C
       CLOSE(1)
111    CONTINUE
       END
