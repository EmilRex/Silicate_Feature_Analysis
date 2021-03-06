; +
; NAME
;  qlookup
;
; PURPOSE
;  Recover/calculate silicate features given basic grain properties 
;
; INPUTS
;   GRAINRAD: Radius of grains
;   WAVELENGTH: Array of wavelengths to be modeled
;   OLIVRATIO: Ratio of olivine, w.r.t. number density. 
;              Assume the rest is pyroxene.
;   CRYSFRAC:
;   FORSTFRAC:
;
; KEYWORDS
;   SEPARATE: Keeps graintypes separate instead of mixing
;
; OUTPUTS
;   QABS: Value returned for actual spectrum modeling
;   Q*** = tables of Q values
;   QEXT: 
;   QSCAT: 
;
; AUTHORS
;  Tushar Mittal - mittal.tushar22@gmail.com
;  Christine Chen - cchen@stsci.edu
;  Emil Christensen - chris2er@dukes.jmu.edu
;
; DISCLAIMER
;  This software is provided as is without any warranty whatsoever.
;  Permission to use, copy, modify, and distribute modified or
;  unmodified copies is granted, provided this disclaimer
;  is included unchanged.
;
; MODIFICATION HISTORY
;  Written by TM (June 2013) as qlookup.pro
;  Organized and commented by EC (6/27/2014)
; -
; *************************************************** ;

pro qlookup, grainrad, wavelength, olivratio, crysfrac, forstfrac, icefrac, $
             qabs, qext=qext, qscat=qscat, separate=separate

; Carry global variables relating to silicate features
COMMON grainprops, qastrosil, qolivine, qpyroxene, qenstatite, qforsterite, qwaterice, crystallineabs
                         
qextall = dblarr(n_elements(grainrad), n_elements(wavelength),5)
qscatall = dblarr(n_elements(grainrad), n_elements(wavelength),5)

; agrain indices
ii = interpol(dindgen(n_elements(qastrosil.agrain)), $
              alog(qastrosil.agrain), alog(grainrad) ) $
              < n_elements(qastrosil.agrain)-1.0 


shortl = where(wavelength lt 0.2, nshort)
if nshort gt 0 then begin
; short wavelengths: use astronomical silcates 
  jj = interpol(dindgen(n_elements(qastrosil.lambda)), $
                alog(qastrosil.lambda), alog(wavelength[shortl]) )
  
  qextall[*, shortl,*] = $
     rebin(exp(interpolate(alog(Qastrosil.Qext), ii, jj, /grid)), $
     n_elements(grainrad), nshort, 5)
           
  qscatall[*, shortl,*] = $
     rebin(exp(interpolate(alog(Qastrosil.Qscat), ii, jj, /grid)), $
     n_elements(grainrad), nshort, 5)
      
endif 


; *************************************************** ;
; Compute for each graintype [olivine,pyroxene,forsterite,enstatite,waterice]
; *************************************************** ;


; *************************************************** ;
graintype =0
qstruct = qolivine
;longl = where(wavelength ge min(qstruct.agrain), nlong)
;if nlong gt 0 then begin
  jj = interpol(dindgen(n_elements(qstruct.lambda)), alog(qstruct.lambda), alog(wavelength) )
  qextall[*,*,graintype] = exp(interpolate((Qstruct.logQext), ii, jj, /grid))
  qscatall[*,*,graintype] = exp(interpolate((Qstruct.logQscat), ii, jj, /grid))
;endif


; *************************************************** ;
graintype =1
qstruct = qpyroxene
;longl = where(wavelength ge min(qstruct.agrain), nlong)
;if nlong gt 0 then begin
  jj = interpol(dindgen(n_elements(qstruct.lambda)), alog(qstruct.lambda), alog(wavelength) )
  qextall[*,*,graintype] = exp(interpolate((Qstruct.logQext), ii, jj, /grid))
  qscatall[*,*,graintype] = exp(interpolate((Qstruct.logQscat), ii, jj, /grid))
;endif


; *************************************************** ;
graintype =2
qstruct = qforsterite
;longl = where(wavelength ge min(qstruct.agrain), nlong)
;if nlong gt 0 then begin
  jj = interpol(dindgen(n_elements(qstruct.lambda2)), alog(qstruct.lambda2), alog(wavelength) )
  qextall[*,*,graintype] = exp(interpolate((Qstruct.logQext2), ii, jj, /grid))
  qscatall[*,*,graintype] = exp(interpolate((Qstruct.logQscat2), ii, jj, /grid))
;endif


; *************************************************** ;
graintype =3
qstruct = qenstatite
;longl = where(wavelength ge min(qstruct.agrain), nlong)
;if nlong gt 0 then begin
  jj = interpol(dindgen(n_elements(qstruct.lambda)), alog(qstruct.lambda), alog(wavelength) )
  qextall[*,*,graintype] = exp(interpolate((Qstruct.logQext), ii, jj, /grid))
  qscatall[*,*,graintype] = exp(interpolate((Qstruct.logQscat), ii, jj, /grid))
;endif

; *************************************************** ;
graintype =4
qstruct = qwaterice
;longl = where(wavelength ge min(qstruct.agrain), nlong)
;if nlong gt 0 then begin
jj = interpol(dindgen(n_elements(qstruct.lambda)), alog(qstruct.lambda), alog(wavelength) )
qextall[*,*,graintype] = exp(interpolate((Qstruct.logQext), ii, jj, /grid))
qscatall[*,*,graintype] = exp(interpolate((Qstruct.logQscat), ii, jj, /grid))
;endif


; *************************************************** ;
; MIX
; olivratio = olivine/(pyroxene+olivine)
; crysfrac = crystalline/(crystalline+amorphous)
; forstfrac = forsterite/(enstatite+forsterite)

; Compresses the 5 *grain* layers into one 2D sheet
; Can probably work around with a keyword at top: /separate or something

IF NOT KEYWORD_SET(separate) THEN BEGIN

  qext = reform( qextall[*,*,0]*olivratio*(1.0-crysfrac)*(1.0-icefrac) + $
                 qextall[*,*,1]*(1.0-olivratio)*(1.0-crysfrac)*(1.0-icefrac) + $
                 qextall[*,*,2]*forstfrac*crysfrac*(1.0-icefrac) + $
                 qextall[*,*,3]*(1.0-forstfrac)*crysfrac*(1.0-icefrac) + $
                 qextall[*,*,4]*icefrac, $
                 n_elements(grainrad), n_elements(wavelength) )
  
  qscat = reform( qscatall[*,*,0]*olivratio*(1.0-crysfrac)*(1.0-icefrac) + $
                  qscatall[*,*,1]*(1.0-olivratio)*(1.0-crysfrac)*(1.0-icefrac) + $
                  qscatall[*,*,2]*forstfrac*crysfrac*(1.0-icefrac) + $
                  qscatall[*,*,3]*(1.0-forstfrac)*crysfrac*(1.0-icefrac) + $
                  qscatall[*,*,4]*icefrac, $
                  n_elements(grainrad), n_elements(wavelength) )

qabs = qext-qscat

ENDIF ELSE BEGIN
  
  qabs = dblarr(n_elements(grainrad),n_elements(wavelength),5)
  qext = dblarr(n_elements(grainrad),n_elements(wavelength),5)
  qscat = dblarr(n_elements(grainrad),n_elements(wavelength),5)
  
  qext[*,*,0] = qextall[*,*,0]*olivratio*(1.0-crysfrac)*(1.0-icefrac)
  qext[*,*,1] = qextall[*,*,1]*(1.0-olivratio)*(1.0-crysfrac)*(1.0-icefrac)
  qext[*,*,2] = qextall[*,*,2]*forstfrac*crysfrac*(1.0-icefrac)
  qext[*,*,3] = qextall[*,*,3]*(1.0-forstfrac)*crysfrac*(1.0-icefrac)
  qext[*,*,4] = qextall[*,*,4]*icefrac
  
  qscat[*,*,0] = qscatall[*,*,0]*olivratio*(1.0-crysfrac)*(1.0-icefrac)
  qscat[*,*,1] = qscatall[*,*,1]*(1.0-olivratio)*(1.0-crysfrac)*(1.0-icefrac)
  qscat[*,*,2] = qscatall[*,*,2]*forstfrac*crysfrac*(1.0-icefrac)
  qscat[*,*,3] = qscatall[*,*,3]*(1.0-forstfrac)*crysfrac*(1.0-icefrac)
  qscat[*,*,4] = qscatall[*,*,4]*icefrac
  
  
  FOR i=0,4 DO qabs[*,*,i] = qext[*,*,i] - qscat[*,*,i]
  
ENDELSE


return
end
