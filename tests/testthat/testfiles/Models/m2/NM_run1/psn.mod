;; 1. Based on: m1
;; 2. Description: 1CMT+oral
;; x1. Author: klgk669
$PROBLEM    THEOPP example
;; 4. Date: 01.01.2011

;; 5. Version: 1

;; 6. Label:

;; Basic model

;; 7. Structural model:

;; One compartment model

;; 8. Covariate model:

;; No covariates

;; 9. Inter-individual variability:

;; CL and V1.

;; 10. Inter-occasion variability:

;; No IOV

;; 11. Residual variability:

;; Additive + Proportional

;; 12. Estimation:

;; IMP
$INPUT      ID AMT TIME DV WT
$DATA      THEOPP.csv IGNORE=@
$SUBROUTINE ADVAN4
$PK 

TVKA=EXP(THETA(1))
MU_1=LOG(TVKA)
KA = EXP(MU_1+ETA(1))

TVK=EXP(THETA(2))
MU_2=LOG(TVK)
K = EXP(MU_2+ETA(2))

TVV2=EXP(THETA(3))
MU_3=LOG(TVV2)
V2 = EXP(MU_3+ETA(3))

CL = K*V2

S2 = V2

TVK23=EXP(THETA(6))
MU_4=LOG(TVK23)
K23 = EXP(MU_4+ETA(4))
TVK32=EXP(THETA(7))
MU_5=LOG(TVK32)
K32 = EXP(MU_5+ETA(5))
$ERROR 

IPRED=F
W=SQRT(THETA(4)**2+THETA(5)**2*IPRED*IPRED)  ; proportional + additive error
IRES=DV-IPRED
IWRES=IRES/W
Y=IPRED+W*EPS(1)


$THETA  1 ; KA; h-1 ;LOG
 -2.5 ; K; h-1 ;LOG
 -0.5 ; V2; L ;LOG
 0.1 ; add error
 0.1 ; prop error
 0.095 ; TVK23; ;LOG
 0.095 ; TVK32; ;LOG
$OMEGA  0.1  ;     IIV_KA  ;        LOG
 0.1  ;      IIV_K  ;        LOG
 0.1  ;     IIV_V2  ;        LOG
 0.1  ;    IIV_K23  ;        LOG
 0.1  ;    IIV_K32  ;        LOG
$SIGMA  1  FIX
; Parameter estimation - FOCE
$ESTIMATION METHOD=1 INTER NOABORT MAXEVAL=9999 PRINT=1 NSIG=3 SIGL=9
; Parameter estimation - IMP

;$EST METHOD=IMP ISAMPLE=300 NITER=300 RANMETHOD=3S2P

;CTYPE=3 CITER=10 CALPHA=0.05 CINTERVAL=3

;PRINT=1 NOABORT INTERACTION GRD=DDDSS

; Parameer estimation - SAEM

;$EST METHOD=SAEM ISAMPLE=2 NBURN=1000 NITER=500 RANMETHOD=3S2P

;CTYPE=3 CITER=10 CALPHA=0.05 CINTERVAL=10

;PRINT=1 NOABORT INTERACTION GRD=DDDSS

; Objective function and covariance evaluation

;$EST METHOD=IMP INTER EONLY= 1 MAPITER=0 ISAMPLE = 2000 NITER = 10 RANMETHOD=3S2P NOABORT PRINT=1 NSIG=3 SIGL=9 GRD=DDDSS
$COVARIANCE PRINT=E UNCONDITIONAL SIGL=10
$TABLE      ID TIME IPRED IWRES IRES CWRES NPDE FILE=sdtabm2 NOPRINT
            ONEHEADER FORMAT=tF13.4
$TABLE      ID ETAS(1:LAST) ; individual parameters
            FILE=patabm2 NOPRINT ONEHEADER FORMAT=tF13.4
$TABLE      ID ; continuous covariates
            FILE=cotabm2 NOPRINT ONEHEADER FORMAT=tF13.4
$TABLE      ID ; categorical covariates
            FILE=catabm2 NOPRINT ONEHEADER FORMAT=tF13.4

