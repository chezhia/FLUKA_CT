*** FIXED Rotation for AXIAL SCANS Disabled due to unknown ERROR
*Generic CT source for any collimation size, SFOV size, static tube or 
*rotating tube, Without filter or Filter modeled using a discrete bowtie
*profile and corresponding energy spectrum. 
*** Needs OPEN Statement in FLUKA input with the following options***
* (1) WHASOU(1)  - 0 - Uniform Rotation - Axial
*                - 1 - Static TUBE at 0 degrees. (12 0 clock)
*                - 2 - Static Tube at 90 degrees.
*                - 3 - Static Tube at 180 degrees.
*                - 4 - Static Tube at 270 degrees.
*                - (-1) - Helical Tube - Head First (+z to -z)
*                - (-2) - Helical Tube - Feet First (-z to +z)
* (2) WHASOU(2)  - TUB2ISO - Tube to Iso-center distance
* (3) WHASOU(3)  - Part. Energy (KeV) - Highest particle energy 
*                                     - Overridden if spectrum provided.
* (4) WHASOU(4)  - Z location of the Tube - Fixed location for Axial 
*                                         - Starting location for Helica
* (5) WHASOU(5)  - Collimation Width (cm)
* (6) WHASOU(6)  - SFOV  		    - Scan Field of View 
* (7) WHASOU(7)  - [UnitNO]  - If WHASOU(7) = 0, WHASOU(8) = 0, Monoener
*                            - If WHASOU(7) > 0, WHASOU(8) = 0, 1 Spectr
*                            - If WHASOU(7) > 0, WHASOU(8) > 0, Spectrum
*							   for half the points in the Bowtie file.
* (8) WHASOU(8)  -    0     - No Bowtie Filter.
*                - [UnitNO] - File with Bowtie profile
*                           - from -25 to 25 (for SFOV of 50cm)
* (9) WHASOU(9)  -    0     - No Heel Profile 
*                - [UnitNO] - File with HEEL PROFILE .
*(10) WHASOU(10) -    0     - IF WHASOU(1) = 0,Uniform Rotation, axial
*                -   PITCH  - IF WHASOU(1) < 0, Pitch in CM   , helical
*(11) WHASOU(11) - Part. History - If WHASOU(10) > 0
*                                  and WHASOU(11) must be a multiple 
*                                  of number of locs in the Rotation.
*                -    0          - If WHASOU(10) = 0
*(12) WHASOU(12) -   TOTROT  - Total number of Tube Rotations 
*                            - For helical scan - ExpTime/Time_1Rotation
*(13) WHASOU(13) -   WHASOU(13) - Starting Position of tube in Helical 
*                               - Scans (Radians)
*(14) WHASOU(14) -   [UnitNO]   - File Containing PDF for TCM from SCAN
*                                 for helical scans
*				        0       - For Axial Scans
*=== source ===========================================================*
*
      SUBROUTINE SOURCE ( NOMORE )
      INCLUDE '(DBLPRC)'
      INCLUDE '(DIMPAR)'
      INCLUDE '(IOUNIT)'
*
*----------------------------------------------------------------------*
*                                                                      *
*     Copyright (C) 1990-2010      by    Alfredo Ferrari & Paola Sala  *
*     All Rights Reserved.                                             *
*                                                                      *
*                                                                      *
*     New source for FLUKA9x-FLUKA20xy:                                *
*                                                                      *
*     Created on 07 January 1990   by    Alfredo Ferrari & Paola Sala  *
*                                                   Infn - Milan       *
*                                                                      *
*     Last change on  17-Oct-10    by    Alfredo Ferrari               *
*                                                                      *
*  This is just an example of a possible user written source routine.  *
*  note that the beam card still has some meaning - in the scoring the *
*  maximum momentum used in deciding the binning is taken from the     *
*  beam momentum.  Other beam card parameters are obsolete.            *
*                                                                      *
*       Output variables:                                              *
*                                                                      *
*              Nomore = if > 0 the run will be terminated              *
*                                                                      *
*----------------------------------------------------------------------*
*
      INCLUDE '(BEAMCM)'
      INCLUDE '(FHEAVY)'
      INCLUDE '(FLKSTK)'
      INCLUDE '(IOIOCM)'
      INCLUDE '(LTCLCM)'
      INCLUDE '(PAPROP)'
      INCLUDE '(SOURCM)'
      INCLUDE '(SUMCOU)'
*
      LOGICAL LFIRST
*
      SAVE LFIRST
      DATA LFIRST / .TRUE. /
*  *** Declare Arrays to read source PDF and save as CDF  ***
*     
      REAL*8 PITCH, PI2
*	  
      INTEGER B, H
      REAL*8 B_HEIGHT,CUM_B,MAGVEC,HCA,TUB2ISO,TABFEED,TOTROT,TABMOV
      REAL*8 Z_DIST, CUM_H, H_BIN, B_BIN
      DIMENSION B_HEIGHT(1:51),CUM_B(1:51),Z_DIST(1:201),CUM_H(1:201)
      SAVE B, B_HEIGHT, CUM_B, Z_DIST, CUM_H, H, H_BIN,TABMOV, B_BIN
*
      INTEGER NMAX, T
      PARAMETER (NMAX=500)
      REAL*8 ERG, CE, E_MAX, TCM, ZCM, SLT
      DIMENSION ERG(1:NMAX), CE(1:NMAX,1:26), ZCM(1:NMAX), TCM(1:NMAX)
      SAVE N, ERG, E_MAX, CE, SLT, T, TCM, ZCM
*
      SAVE HCA,HFA,TUB2ISO,SFOV, PITCH, TABFEED, TOTROT, PI2
*
*======================================================================*
*                                                                      *
*                 BASIC VERSION                                        *
*                                                                      *
*======================================================================*
      NOMORE = 0
*  +-------------------------------------------------------------------*
********************************
*  |  First call initializations:
      IF ( LFIRST ) THEN
*  |  *** The following 3 cards are mandatory ***
         TKESUM = ZERZER
         LFIRST = .FALSE.
         LUSSRC = .TRUE.
*
*  |  *** User initialization ***
*
       WRITE(*,*) 'Generic CT source with EDITS ON'
* Tube to Isocenter Distance
        TUB2ISO = WHASOU(2)
* SCAN FIELD OF VIEW 'LARGE BODY'
        SFOV = WHASOU(6)
* HCA, WHASOU(5)-Det. Coverage, 
        HCA = ATAN(WHASOU(5)/2/TUB2ISO)
* For 32cm SFOV and 60cm Tub2iso
        HFA = ATAN(SFOV/2/TUB2ISO)
* Total Number of Rotations in the Scan		
		TOTROT = WHASOU(12)
* Check if Helical SCAN
		IF (WHASOU(1).LT. ZERZER) THEN
        PITCH =  WHASOU(10)
* Distance Travelled in One Rotation		 
		TABFEED = PITCH*WHASOU(5)
* Define 2PI		
		PI2 = 2*3.1415927
		END iF
* Total Z length traversed by the table		
	    TABMOV = TABFEED * TOTROT 
* Check For HEEL Profile CDF
	    IF (WHASOU(9) .GT. ZERZER) THEN
***** Read HEEL Profile File ****
		LUNRD = NINT(WHASOU(9))
*			WRITE(*,*) 'LUNRD is ', LUNRD
		 H = 0
 150      CONTINUE
			 READ(LUNRD, *, ERR=9999, END=160) HEIGHT,CDF 
			 IF (CDF .GT. AZRZRZ) THEN
			 H = H + 1         
			 Z_DIST (H) = HEIGHT
			 CUM_H (H) = CDF
			 END IF
		  GOTO 150
 160	  CONTINUE 
          H_BIN = (Z_DIST(2)-Z_DIST(1))
		  CLOSE (LUNRD)
 		  WRITE(*,*) 'HEEL File Read, Bin Size', H_BIN
       END IF
* Read E_Max, the energy that will be used if no spectrum file is provid
        E_MAX = WHASOU(3)/1000000  
* Check For BOWTIE Profile CDF
       IF (WHASOU(8) .GT. ZERZER) THEN
**** Read BOWTIE Profile File ****
       LUNRD = NINT(WHASOU(8))
       WRITE(*,*) 'LUNRD is ', LUNRD
          B = 0
 250   CONTINUE
         READ(LUNRD, *, ERR=9999, END=260) HEIGHT,CDF 
       IF (CDF .GT. AZRZRZ) THEN
         B = B + 1         
         B_HEIGHT (B) = HEIGHT
         CUM_B (B) = CDF
       END IF
       GOTO 250
 260   CONTINUE 
         B_BIN = (B_HEIGHT(2)-B_HEIGHT(1))
         CLOSE (LUNRD)
       WRITE(*,*) 'BOWTIE File Read'
**** Read spectrum ***
       LUNRD = NINT(WHASOU(7))
       WRITE(*,*) 'LUNRD is ', LUNRD
       N = 0
       EPREV = ZERZER
 350   CONTINUE
       N = N+1
       READ(LUNRD, *, ERR=9999, END=360) E,CE(N,1),CE(N,2),CE(N,3),
     &  CE(N,4),CE(N,5),CE(N,6),CE(N,7),CE(N,8),CE(N,9),CE(N,10),
     &  CE(N,11),CE(N,12),CE(N,13),CE(N,14),CE(N,15),CE(N,16),CE(N,17),
     &  CE(N,18),CE(N,19),CE(N,20),CE(N,21),CE(N,22),CE(N,23),CE(N,24),
     &  CE(N,25), CE(N,26)
        E2 = E/1000000          
*        WRITE(*,*) 'E2 = ',E, ' 10 ',CE(N,10),' 20 ',CE(N,20)
        EPREV  = E2
        ERG(N) = E2
       GOTO 350
 360   CONTINUE 
       CLOSE (LUNRD)
       WRITE(*,*) 'BOWTIE Spectrum Read'
**** Read spectrum for no BOWTIE***
	   ELSE IF (WHASOU(7) .GT. ZERZER) THEN
       LUNRD = NINT(WHASOU(7))
       WRITE(*,*) 'LUNRD is ', LUNRD
       N = 0
       EPREV = ZERZER
 450   CONTINUE
       N = N+1
       READ(LUNRD, *, ERR=9999, END=460) E,CE(N,1)
       E2 = E/1000000          
*       WRITE(*,*) 'E2 = ', E, 'CE = ', CE(N,1)
       EPREV  = E2
       ERG(N) = E2
       GOTO 450
 460   CONTINUE
       CLOSE (LUNRD)
       WRITE(*,*) 'Source spec Read for Central Ray - no BOWTIE'
       END IF
**** Check TCM File ***
       IF((WHASOU(1) .LT. ZERZER) .AND. (WHASOU(14) .GT. ZERZER) ) THEN
*  |*** Location file called ***|
	   LUNRD = NINT(WHASOU(14))
       WRITE(*,*) 'LUNRD is ', LUNRD
       T = 0
 570   CONTINUE
       READ(LUNRD, *, ERR=9999, END=580) ZT,PT
	   WRITE(*,*) 'Reading TCM File ',T
        T = T+1
        ZCM (T) = ZT/10
        TCM (T) = PT
       GOTO 570
 580   CONTINUE 
       CLOSE (LUNRD)
	   SLT = ZCM(2)-ZCM(1)
 	   WRITE(*,*) 'TCM File Read', T
	   END IF
       END IF
********************************
*  |
*  +-------------------------------------------------------------------*
*  Push one source particle to the stack. Note that you could as well
*  push many but this way we reserve a maximum amount of space in the
*  stack for the secondaries to be generated
*  Npflka is the stack counter: of course any time source is called it
*  must be =0
      NPFLKA = NPFLKA + 1
*  Particle type (1=proton.....). Ijbeam is the type set by the BEAM
*  card
*  +-------------------------------------------------------------------*
*  |  (Radioactive) isotope:
      IF ( IJBEAM .EQ. -2 .AND. LRDBEA ) THEN
         IARES  = IPROA 
         IZRES  = IPROZ
         IISRES = IPROM
         CALL STISBM ( IARES, IZRES, IISRES )
         IJHION = IPROZ  * 1000 + IPROA
         IJHION = IJHION * 100 + KXHEAV
         IONID  = IJHION
         CALL DCDION ( IONID )
         CALL SETION ( IONID )
*  |
*  +-------------------------------------------------------------------*
*  |  Heavy ion:
      ELSE IF ( IJBEAM .EQ. -2 ) THEN
         IJHION = IPROZ  * 1000 + IPROA
         IJHION = IJHION * 100 + KXHEAV
         IONID  = IJHION
         CALL DCDION ( IONID )
         CALL SETION ( IONID )
         ILOFLK (NPFLKA) = IJHION
*  |  Flag this is prompt radiation
         LRADDC (NPFLKA) = .FALSE.
*  |  Group number for "low" energy neutrons, set to 0 anyway
         IGROUP (NPFLKA) = 0
*  |
*  +-------------------------------------------------------------------*
*  |  Normal hadron:
      ELSE
         IONID = IJBEAM
         ILOFLK (NPFLKA) = IJBEAM
*  |  Flag this is prompt radiation
         LRADDC (NPFLKA) = .FALSE.
*  |  Group number for "low" energy neutrons, set to 0 anyway
         IGROUP (NPFLKA) = 0
      END IF
*  |
*  +-------------------------------------------------------------------*
*  From this point .....
*  Particle generation (1 for primaries)
      LOFLK  (NPFLKA) = 1
*  User dependent flag:
      LOUSE  (NPFLKA) = 0
*  No channeling:
      LCHFLK (NPFLKA) = .FALSE.
      DCHFLK (NPFLKA) = ZERZER
*  User dependent spare variables:
      DO 100 ISPR = 1, MKBMX1
         SPAREK (ISPR,NPFLKA) = ZERZER
 100  CONTINUE
*  User dependent spare flags:
      DO 200 ISPR = 1, MKBMX2
         ISPARK (ISPR,NPFLKA) = 0
 200  CONTINUE
*  Save the track number of the stack particle:
      ISPARK (MKBMX2,NPFLKA) = NPFLKA
      NPARMA = NPARMA + 1
      NUMPAR (NPFLKA) = NPARMA
      NEVENT (NPFLKA) = 0
      DFNEAR (NPFLKA) = +ZERZER
*  ... to this point: don't change anything
*  Particle age (s)
      AGESTK (NPFLKA) = +ZERZER
      AKNSHR (NPFLKA) = -TWOTWO
* Based on WBEAM, Particle weight fixed
      WTFLK (NPFLKA) = ONEONE
      WEIPRI = WEIPRI + WTFLK (NPFLKA)
*
* Find Z location first
* AXIAL SCAN
      IF(WHASOU(1) .GE. 0) THEN
      ZFLK (NPFLKA) = WHASOU(4)
	  ELSE IF (WHASOU(14) .EQ. ZERZER) THEN
* HELICAL SCAN, NO TCM	  
	  R = FLRNDM(R)
	  IF(WHASOU(1) .EQ. -1) THEN
* HEAD First Scan
      ZFLK (NPFLKA) = WHASOU(4) - TABMOV*R
      ELSE
* FEET First Scan
	  ZFLK (NPFLKA) = WHASOU(4) + TABMOV*R
	  END IF	 
	  ELSE 
* HELICAL SCAN, WITH TCM	
	  R = FLRNDM(R)
	  DO J = 1,T
      IF (TCM(J) .GT. R) THEN
       R = FLRNDM(R)
	   ZLOC = ZCM(J) + SLT * R
      GOTO 790
      END IF
      END DO  
 790  CONTINUE
*      WRITE(*,*) 'Sampled Zloc = ', ZLOC, WHASOU(4) 
	  IF(WHASOU(1) .EQ. -1) THEN
* HEAD First Scan
      ZFLK (NPFLKA) = WHASOU(4) - ZLOC
      ELSE
* FEET First Scan
	  ZFLK (NPFLKA) = WHASOU(4) + ZLOC
	  END IF
      END IF	  
*	  
*  Particle coordinates, find X, Y location
* IF WHASOU(1) = 0,sample around the Gantry (ROTATION) 
      IF (WHASOU(1) .EQ. ZERZER) THEN
*  Particle coordinates
* Sample Uniformly around the GANTRY (random angles)
* Reference for sampling method - von Neumann 1951, Cook 1957.	  
500	  CONTINUE      
      X1 = 2*FLRNDM(X1) - 1
      X2 = 2*FLRNDM(X2) - 1
      X1SQ = X1**2
      X2SQ = X2**2 
      TSQ  = X1SQ+X2SQ
      IF (TSQ .GE. 1.0) THEN
      GOTO 500
      END IF
      XFLK (NPFLKA) =  TUB2ISO*(X1SQ-X2SQ)/TSQ
      YFLK (NPFLKA) =  TUB2ISO*2*X1*X2/TSQ
* Else 1 - 0 deg, 2- 90 deg, 3 - 180 deg, 4 - 270 deg
      ELSE IF (WHASOU(1) .EQ. 1) THEN
      XFLK   (NPFLKA) = 0
      YFLK   (NPFLKA) = TUB2ISO
      ELSE IF (WHASOU(1) .EQ. 2) THEN
      XFLK   (NPFLKA) = TUB2ISO
      YFLK   (NPFLKA) = 0
      ELSE IF (WHASOU(1) .EQ. 3) THEN
      XFLK   (NPFLKA) = 0
      YFLK   (NPFLKA) = -TUB2ISO
      ELSE IF (WHASOU(1) .EQ. 4) THEN
      XFLK   (NPFLKA) = -TUB2ISO
      YFLK   (NPFLKA) = 0
	  ELSE
*Helical scan (From Li's paper, page-399)
      R = FLRNDM(R)
      BETA = ABS(ZFLK (NPFLKA) - WHASOU(4)) * PI2/TABFEED 
	  BETAROT = BETA + WHASOU(13)
      XFLK (NPFLKA) = TUB2ISO*SIN(BETAROT)
      YFLK (NPFLKA) = TUB2ISO*COS(BETAROT)
      END IF
*      WRITE(LUNOUT,*) 'Samp. Location ', XFLK(NPFLKA), YFLK(NPFLKA)
* Polar Angle based on Detector Coverage (NxT)
****************
* IF HEEL PROFILE present
      IF (WHASOU(9) .GT. ZERZER) THEN
	  R = FLRNDM(R)
	  DO J = 1,H
      IF (CUM_H(J) .GT. R) THEN
      ZDIST = Z_DIST(J)
*     WRITE(LUNOUT,*) 'Sampled Z Bin', J
      GOTO 700
      END IF
      END DO  
 700  CONTINUE 
*     Sample Polar angle uniformly within angular bin sampled
      R = FLRNDM(R)
	  ZDIST = ZDIST + (H_BIN*R) - (H_BIN/2)
* Finding Angle from the sampled Height
      P = -ATAN(ZDIST/TUB2ISO)
* IF NO HEEL PROFILE Present	  
      ELSE
      R = FLRNDM(R)
      P = 2*R*HCA - HCA
      END IF
***************	  
* Rotate sampled Polar Angle  
      P = P + 1.570796327
*      WRITE(LUNOUT,*) 'Sampled Polar angle', P
*
* Sample Azimuthal angle
***************
* Check for BOWTIE CDF
      IF (WHASOU(8) .GT. ZERZER) THEN
       R = FLRNDM(R)
      DO J = 1,B
      IF (CUM_B(J) .GT. R) THEN
       A = B_HEIGHT(J)
*      WRITE(LUNOUT,*) 'Sampled Height Bin', J
      GOTO 300
      END IF
      END DO  
 300  CONTINUE 
* Sample Azimuthal angle (A) uniformly within angular bin sampled
       R = FLRNDM(R)
       A = A + (B_BIN*R) - (B_BIN/2)
* Finding Angle from the sampled Height
      PHI = ATAN(A/TUB2ISO)
*  Choose the correct CDF for the Energy Spectrum based on the sampled F
       X = B/2
       X = NINT(X)
       IF (J .LE. X) THEN
        K = J 
       ELSE 
        K = 1+(B-J)
       END IF
** IF NO BOWTIE Profile Present
      ELSE
      R = FLRNDM(R)
      PHI = 2*R*HFA - HFA
      K = 1
      END IF
****************
*
* Sample Kinetic energy of the particle (GeV)
****************
* For Spectral source
      IF(WHASOU(7) .GT. ZERZER) THEN
      R = FLRNDM(R) 
      DO I = 1,N
      IF (CE(I,K) .GE. R) THEN
       TKEFLK (NPFLKA)= SQRT(ERG(I)**2)
      GOTO 400
      END IF
      END DO     
 400  CONTINUE
*      WRITE(LUNOUT,*) 'I ',I,' CUM ',CE(I,K),' R ', R
* For Monoenergetic source
      ELSE
	   TKEFLK (NPFLKA)= SQRT(E_MAX**2)
      END IF
****************	
*
*  Particle momentum
*     PMOFLK (NPFLKA) = PBEAM
      PMOFLK (NPFLKA) = SQRT ( TKEFLK (NPFLKA) * ( TKEFLK (NPFLKA)
     &  + TWOTWO * AM (IONID) ) )
*
*
      PHI = PHI + ACOS(XFLK (NPFLKA)
     & /SQRT(XFLK (NPFLKA)**2 + YFLK (NPFLKA)**2))
*      WRITE(LUNOUT,*) 'Sampled Final PHI', PHI
*
* Sample Direction Vector
*
         UBEAM = -COS(PHI)*SIN(P)
      IF (YFLK(NPFLKA) .GT. ZERZER) THEN
         VBEAM = -SIN(PHI)*SIN(P)
      ELSE
         VBEAM =  SIN(PHI)*SIN(P)
      END IF
         WBEAM =  COS(P)
*      WRITE(LUNOUT,*) 'Direction Vector is ', UBEAM, VBEAM, WBEAM
      IF(ANINT(SQRT(UBEAM**2 + VBEAM**2 + ZBEAM**2)) .EQ. 1.00) THEN
        GOTO 600
      ELSE
        GOTO 9998
      END IF      
600   CONTINUE
      TXFLK  (NPFLKA) = UBEAM
      TYFLK  (NPFLKA) = VBEAM
      TZFLK  (NPFLKA) = WBEAM
*     TZFLK  (NPFLKA) = SQRT ( ONEONE - TXFLK (NPFLKA)**2
*    &                       - TYFLK (NPFLKA)**2 )
*  Polarization cosines:
      TXPOL  (NPFLKA) = -TWOTWO
      TYPOL  (NPFLKA) = +ZERZER
      TZPOL  (NPFLKA) = +ZERZER
*  Calculate the total kinetic energy of the primaries: don't change
      IF ( ILOFLK (NPFLKA) .EQ. -2 .OR. ILOFLK (NPFLKA) .GT. 100000 )
     &   THEN
         TKESUM = TKESUM + TKEFLK (NPFLKA) * WTFLK (NPFLKA)
      ELSE IF ( ILOFLK (NPFLKA) .NE. 0 ) THEN
         TKESUM = TKESUM + ( TKEFLK (NPFLKA) + AMDISC (ILOFLK(NPFLKA)) )
     &          * WTFLK (NPFLKA)
      ELSE
         TKESUM = TKESUM + TKEFLK (NPFLKA) * WTFLK (NPFLKA)
      END IF
      RADDLY (NPFLKA) = ZERZER
*  Here we ask for the region number of the hitting point.
*     NREG (NPFLKA) = ...
*  The following line makes the starting region search much more
*  robust if particles are starting very close to a boundary:
      CALL GEOCRS ( TXFLK (NPFLKA), TYFLK (NPFLKA), TZFLK (NPFLKA) )
      CALL GEOREG ( XFLK  (NPFLKA), YFLK  (NPFLKA), ZFLK  (NPFLKA),
     &              NRGFLK(NPFLKA), IDISC )
*  Do not change these cards:
      CALL GEOHSM ( NHSPNT (NPFLKA), 1, -11, MLATTC )
      NLATTC (NPFLKA) = MLATTC
      CMPATH (NPFLKA) = ZERZER
      CALL SOEVSV
      RETURN
9998  CONTINUE
      MAGVEC = ANINT(SQRT(UBEAM**2 + VBEAM**2 + ZBEAM**2))
      WRITE(LUNOUT,*) 'Sampled direction not unit vector', MAGVEC
      RETURN
9999  CONTINUE
      WRITE(LUNOUT,*) 'Error Reading Source spec File'
*=== End of subroutine Source =========================================*
