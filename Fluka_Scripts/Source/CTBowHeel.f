*Generic CT source for any collimation size, SFOV size, static tube or 
*rotating tube, Without filter or Filter modeled using a discrete bowtie
*profile and corresponding energy spectrum. 
*** Needs OPEN Statement in FLUKA input with the following options***
* (1) WHASOU(1) - 0 - Uniform Rotation
*               - 1 - Static TUBE at 0 degrees. (12 0 clock)
*               - 2 - Static Tube at 90 degrees.
*               - 3 - Static Tube at 180 degrees.
*               - 4 - Static Tube at 270 degrees.
* (2) WHASOU(2) - 0 - No Bowtie Filter.
*               - [UnitNo] - File with Bowtie profile
*                          - from -25 to 25 (for Usual SFOV of 50cm)
* (3) WHASOU(3) - [UnitNo] - If WHASOU(2) = 0, only one spectrum.
*                          - If WHASOU(3) > 0,  Spectrum for
*                            half the points in the Bowtie file (Symmetry)
* (4) WHASOU(4) - Z location of the Tube 
* (5) WHASOU(5) - Collimation Width (cm)
* (6) WHASOU(6) - [UnitNO]  - File withHEEL PROFILE .
*                     0     - No Heel Profile                                                
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
      INTEGER B, H
      REAL*8 B_HEIGHT, CUM_B, MAGVEC, HCA, TUB2ISO, X1, X2
      REAL*8 Z_DIST, CUM_H, H_BIN
      DIMENSION B_HEIGHT(1:51),CUM_B(1:51),Z_DIST(1:51),CUM_H(1:51)
      SAVE B, B_HEIGHT, CUM_B, Z_DIST, CUM_H, H, H_BIN
*
      INTEGER NMAX
      PARAMETER (NMAX=500)
      REAL*8 ERG, CE, CUM
      DIMENSION ERG(1:NMAX), CE(1:NMAX,1:26)
      SAVE N, ERG
      SAVE CE
*
      SAVE HCA,HFA,TUB2ISO,X1,X2,SFOV
*
*======================================================================*
*                                                                      *
*                 BASIC VERSION                                        *
*                                                                      *
*======================================================================*
      NOMORE = 0
*  +-------------------------------------------------------------------*
*  |  First call initializations:
      IF ( LFIRST ) THEN
*  |  *** The following 3 cards are mandatory ***
         TKESUM = ZERZER
         LFIRST = .FALSE.
         LUSSRC = .TRUE.
*
*  |  *** User initialization ***
*
       WRITE(LUNOUT,*) 'Generic CT source with EDITS ON'
* Tube to Isocenter Distance
         TUB2ISO = 62.56
* SCAN FIELD OF VIEW 'LARGE BODY'
         SFOV = 50
* HCA, WHASOU(5)-Det. Coverage, 
         HCA = ATAN(WHASOU(5)/2/TUB2ISO)
* For 32cm SFOV and 60cm Tub2iso
         HFA = ATAN(SFOV/2/TUB2ISO)

* Intialize Random no Seeds
          X1 = 50
          X2 = 100
* Check For HEEL Profile CDF
	   IF (WHASOU(6) .GT. ZERZER) THEN
***** Read HEEL Profile File ****
			LUNRD = NINT(WHASOU(6))
			WRITE(LUNOUT,*) 'LUNRD is ', LUNRD
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
          H_BIN = (Z_DIST(2)-Z_DIST(1))/2
		  CLOSE (LUNRD)
		  WRITE(LUNOUT,*) 'HEEL File Read'
       END IF
* Check For BOWTIE Profile CDF
       IF (WHASOU(2) .GT. ZERZER) THEN
**** Read BOWTIE Profile File ****
       LUNRD = NINT(WHASOU(2))
       WRITE(LUNOUT,*) 'LUNRD is ', LUNRD
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
         CLOSE (LUNRD)
       WRITE(LUNOUT,*) 'BOWTIE File Read'
**** Read spectrum ***
       LUNRD = NINT(WHASOU(3))
       WRITE(LUNOUT,*) 'LUNRD is ', LUNRD
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
        WRITE(LUNOUT,*) 'E2 = ',E, ' 10 ',CE(N,10),' 20 ',CE(N,20)
        EPREV  = E2
        ERG(N) = E2
       GOTO 350
 360   CONTINUE 
       CLOSE (LUNRD)
       WRITE(LUNOUT,*) 'BOWTIE File Read'
       ELSE
**** Read spectrum ***
       LUNRD = NINT(WHASOU(3))
       WRITE(LUNOUT,*) 'LUNRD is ', LUNRD
       N = 0
       EPREV = ZERZER
 450   CONTINUE
       N = N+1
       READ(LUNRD, *, ERR=9999, END=460) E,CE(N,1)
       E2 = E/1000000          
       WRITE(LUNOUT,*) 'E2 = ', E, 'CE = ', CE(N,1)
       EPREV  = E2
       ERG(N) = E2
       GOTO 450
 460   CONTINUE
       CLOSE (LUNRD)
       WRITE(LUNOUT,*) 'Source spec Read for Central Ray'
       END IF
       END IF
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
	  
*  Particle coordinates
* IF WHASOU(1) = 0,sample uniformly around the Gantry (ROTATION) 
* Reference for sampling method - von Neumann 1951, Cook 1957.
      IF (WHASOU(1) .EQ. ZERZER) THEN
 500  CONTINUE      
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
      ELSE 
      XFLK   (NPFLKA) = -TUB2ISO
      YFLK   (NPFLKA) = 0
      END IF
* First Scan
      ZFLK (NPFLKA) = WHASOU(4)
*      WRITE(LUNOUT,*) 'Samp. Location ', XFLK(NPFLKA), YFLK(NPFLKA)
* Polar Angle based on Detector Coverage (NxT)
*
      IF (WHASOU(6) .GT. ZERZER) THEN
	  R = FLRNDM(R)
	  DO J = 1,H
      IF (CUM_H(J) .GT. R) THEN
       ZDIST = Z_DIST(J)
*      WRITE(LUNOUT,*) 'Sampled Z Bin', J
      GOTO 700
      END IF
      END DO  
 700  CONTINUE 
*      Sample Polar angle uniformly within angular bin sampled
      IF ((J .GT. 1 ) .AND. (J .LT. H)) THEN
       R = 1*FLRNDM(R) - H_BIN
       ZDIST = ZDIST + R
      ELSE
       R =   H_BIN*FLRNDM(R)
       IF (J .EQ. 1.00) THEN
        ZDIST = ZDIST + R
       ELSE
        ZDIST = ZDIST - R
       END IF
      END IF
*      WRITE(LUNOUT,*) 'Sampled Height', A, ' in Bin ', J
* Finding Angle from the sampled Height
      P = -ATAN(ZDIST/TUB2ISO)
      ELSE
      R = FLRNDM(R)
      P = 2*R*HCA - HCA
      END IF
* Rotate sampled Polar Angle  
      P = P + 1.570796327
*      WRITE(LUNOUT,*) 'Sampled Polar angle', P
*
* Sample Azimuthal angle
* Check for BOWTIE CDF
      IF (WHASOU(2) .GT. ZERZER) THEN
       R = FLRNDM(R)
      DO J = 1,B
      IF (CUM_B(J) .GT. R) THEN
       A = B_HEIGHT(J)
*      WRITE(LUNOUT,*) 'Sampled Height Bin', J
      GOTO 300
      END IF
      END DO  
 300  CONTINUE 
*
* Sample Azimuthal angle (A) uniformly within angular bin sampled
* 
      IF ((J .GT. 1 ) .AND. (J .LT. B)) THEN
       R = 1*FLRNDM(R) - 0.5
       A = A + R
      ELSE
       R =   0.5*FLRNDM(R)
       IF (J .EQ. 1.00) THEN
        A = A + R
       ELSE
        A = A - R
       END IF
      END IF
*      WRITE(LUNOUT,*) 'Sampled Height', A, ' in Bin ', J
* Finding Angle from the sampled Height
      PHI = ATAN(A/TUB2ISO)
*  Choose the correct CDF for the Energy Spectrum based on the sampled Fan Height
       X = B/2
       X = NINT(X)
       IF (J .LE. X) THEN
        K = J 
       ELSE 
        K = 1+(B-J)
       END IF
*      WRITE(LUNOUT,*) 'B ',B,' J ', J
*      WRITE(LUNOUT,*) 'K ',K,' X ', X
      ELSE
      R = FLRNDM(R)
      PHI = 2*R*HFA - HFA
      K = 1
      END IF
*      WRITE(LUNOUT,*) 'Bowtie Bin ', K, ' Act Bin ', J

* Sample Kinetic energy of the particle (GeV)
*
      R = FLRNDM(R) 
      DO I = 1,N
      IF (CE(I,K) .GE. R) THEN
       TKEFLK (NPFLKA)= SQRT(ERG(I)**2)
      GOTO 400
      END IF
      END DO     
 400  CONTINUE
*      WRITE(LUNOUT,*) 'I ',I,' CUM ',CE(I,K),' R ', R
*
*  Particle momentum
*     PMOFLK (NPFLKA) = PBEAM
      PMOFLK (NPFLKA) = SQRT ( TKEFLK (NPFLKA) * ( TKEFLK (NPFLKA)
     &  + TWOTWO * AM (IONID) ) )
*
*  Cosines (tx,ty,tz)
*  Transform A to Current starting position
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
         VBEAM = SIN(PHI)*SIN(P)
      END IF
         WBEAM = COS(P)
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
      END