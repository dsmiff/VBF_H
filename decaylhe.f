      PROGRAM DECAYLHE
C----
C. Takes the hard-scattered samples of VBF Higgs and decays the Higgs to ZZ, 
C  then ZZ to two neutrino pairs before hadronising and showering
C----

C--------------- PREAMBLE: COMMON BLOCK DECLARATIONS ETC -------------
C...All real arithmetic done in double precision.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
C...The PYTHIA event record:
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      SAVE /PYJETS/
C...Pythia parameters
      COMMON/PYPARS/MSTP(200),PARP(200),MSTI(200),PARI(200)
      COMMON/PYDAT3/MDCY(500,3),MDME(8000,2),BRAT(8000),KFDP(8000,5)

      INTEGER MAXNUP
      PARAMETER (MAXNUP=500)
      INTEGER NUP,IDPRUP,IDUP,ISTUP,MOTHUP,ICOLUP
      DOUBLE PRECISION XWGTUP,SCALUP,AQEDUP,AQCDUP,PUP,VTIMUP,SPINUP
      COMMON/HEPEUP/NUP,IDPRUP,XWGTUP,SCALUP,AQEDUP,AQCDUP,IDUP(MAXNUP),
     &     ISTUP(MAXNUP),MOTHUP(2,MAXNUP),ICOLUP(2,MAXNUP),PUP(5,MAXNUP)
c     &     VTIMUP(MAXNUP),SPINUP(MAXNUP)

      PARAMETER (NMXHEP=4000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      DOUBLE PRECISION PHEP, VHEP

C...EXTERNAL statement links PYDATA on most machines.
      CHARACTER*3 chlun
      EXTERNAL PYDATA

C-------------------------- PYTHIA SETUP -----------------------------
      

C...1) Open LHEF file on unit LUN, and tell Pythia where to find it.
      LUN=88
      OPEN(LUN,FILE='VBF_inv_LHEs/event_gf_inv_14000.lhe')    !. The LHE sample that needs decaying
 15   OPEN(21, FILE='pythia_events.lhe')
      WRITE(CHLUN,'(I3)') LUN
      WRITE(21, '(a)') '<LesHouchesEvents version="1.0">'
c      WRITE(21,'(a)') '<init>'
c      WRITE(21,'(2i6,2E12.5,2i2,2i6,2i2)')
c     $     K(1,2),K(2,2),P(1,4),P(2,4),0,0,
c     $     0,0,3,1
c      WRITE(21,'(3E12.5,i4)')
c     $     stdxsec,0d0,1d0,100
c      WRITE(21,'(a)') '</init>'

!. Can include this in by hand if necessary

      
      CALL PYGIVE('MSTP(161)='//CHLUN)
      CALL PYGIVE('MSTP(162)='//CHLUN)

C     Turning of/on the necessary Higgs/ Z decays
      CALL PYGIVE('MDME(214,1)=0') ! Turning off the Higgs -> b bar decay
      CALL PYGIVE('MDME(210,1)=0') ! h0->d_dbar off. 
      CALL PYGIVE('MDME(211,1)=0') ! h0->u_ubar off. 
      CALL PYGIVE('MDME(212,1)=0') ! h0->s_sbar off. 
      CALL PYGIVE('MDME(213,1)=0') ! h0->c_cbar off. 
      CALL PYGIVE('MDME(214,1)=0') ! h0->b_bbar off.
      CALL PYGIVE('MDME(215,1)=0') ! h0->t_tbar off.
      CALL PYGIVE('MDME(218,1)=0') ! h0->e+e- off. 
      CALL PYGIVE('MDME(219,1)=0') ! h0->mu+mu- off. 
      CALL PYGIVE('MDME(220,1)=0') ! h0->tau+tau- off.
      CALL PYGIVE('MDME(222,1)=0') ! h0->gg off.
      CALL PYGIVE('MDME(224,1)=0') ! h0->gamma_Z0 off. 
      CALL PYGIVE('MDME(225,1)=1') ! h0->Z0_Z0 ON. 
      CALL PYGIVE('MDME(226,1)=0') ! h0->W+W- off.
      CALL PYGIVE('MDME(223,1)=0') ! h0->gamma_gamma off.

      CALL PYGIVE('MDME(174,1)=0') ! Z0->d_dbar off.
      CALL PYGIVE('MDME(175,1)=0') ! Z0->u_ubar off.
      CALL PYGIVE('MDME(176,1)=0') ! Z0->s_sbar off.
      CALL PYGIVE('MDME(177,1)=0') ! Z0->c_cbar off.
      CALL PYGIVE('MDME(178,1)=0') ! Z0->b_bar off.
      CALL PYGIVE('MDME(179,1)=0') ! Z0->t_tbar off.
      CALL PYGIVE('MDME(182,1)=0') ! Z0->e+e- off.
      CALL PYGIVE('MDME(183,1)=1') ! Z0->nu_e_nu_ebar ON.
      CALL PYGIVE('MDME(184,1)=0') ! Z0->mu_mu+ off.
      CALL PYGIVE('MDME(185,1)=1') ! Z0->nu_mu_nu_mubar ON.
      CALL PYGIVE('MDME(186,1)=0') ! Z0->tau-tau+ off.
      CALL PYGIVE('MDME(187,1)=1') ! Z0->nu_tau_nu_taubar ON.

      
C...2) Initialize Pythia for user process  

      CALL PYINIT('USER',' ',' ',0D0)

C------------------------- GENERATE EVENTS ---------------------------

C...Initial values for number of events and cumulative charged multiplicity
      IEV=0

C     Hadronisation/ISR/FSR etc selections

      MSTP(111)=1               !. Should allow hadronisation 
      MSTP(61)=0
      MSTP(71)=0
      MSTP(161)=0
      MSTP(164)=0
      MSTP(81)=0               !. Multiple interactions


C...Get next event from file and process it
 100    CALL PYEVNT
c        CALL PYHEPC(1)

C...If event generation failed, quit loop
      IF(MSTI(51).EQ.1) THEN
        GOTO 999
      ENDIF


C...Else count up number of generated events
      IEV=IEV+1

      CALL PYHEPC(1)             !. Converting event record of PYJETS to PYHEPC. Want to compare with event record of just PYJETS
      WRITE(21,'(a)') '<event>'
      WRITE(21,'(I3,I4,4E16.8)')
     $     NHEP, 100, 1d0, 0d0, 0d0
      DO I=1,30
         WRITE(21,'(I8,I3,2I3,2I2,5E16.8,2F3.0)')
     $        IDHEP(I),ISTHEP(I),JMOHEP(1,I),JMOHEP(2,I),0,0,
     $        (PHEP(J,I),J=1,5),0d0,0d0
      ENDDO
      WRITE(21,'(a)') '</event>'



C...Print first event, both LHEF input and Pythia output, for information only
      IF(IEV.LE.1) THEN   !. Event 1
        CALL PYLIST(1)
        CALL PYLIST(7)
      ENDIF

C.../PYJETS/ now contains a fully generated event.
C...Insert user analysis here (or save event to output) 
C...(example: count charged multiplicity)

C     NOT NEEDED

C...Loop back to look for next event
      GOTO 100

C...Jump point when end-of-file reached (or other problem encountered)
C...Print final statistics.


 999  CALL PYSTAT(1)


        PRINT *, "Samples decayed, please see above for event listing"
      END
