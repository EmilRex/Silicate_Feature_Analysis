; +
; NAME
;  pso_min_example_m
;
; PURPOSE
;  Search the parameter space with the PSO routine rmd_pso 
;
; INPUTS
;  AMIN:
;  TEFF: 
;  NAME:
;  OUT_PAR:
;  SEQUENCE:
;
; KEYWORDS
;   NONE
;
; OUTPUTS
;  OUTPUT: array containing likelihood (i.e. fitness) values 
;
; AUTHORS
;  Tushar Mittal 
;  Christine Chen
;  Emil Christensen - chris2er@dukes.jmu.edu
;
; DISCLAIMER
;  This software is provided as is without any warranty whatsoever.
;  Permission to use, copy, modify, and distribute modified or
;  unmodified copies is granted, provided this disclaimer
;  is included unchanged.
;
; MODIFICATION HISTORY
;  Adapted from rmd_pso.pro by TM (June 2013) as pso_min_example_m.pro
;  Organized and commented by EC (6/27/2014)
; -
; *************************************************** ;
; 
; 
; ****************************************************************************************************** ;
function f1_eval,p,_EXTRA = extra
; ****************************************************************************************************** ;
; This function has a couple of minima and maxima.  This
; particular function is the one that the algorithm will
; call and evaluate agents positions, one at a time.

; Create global variables relating to silicate features
COMMON grainprops, Qastrosil, Qolivine, Qpyroxene, Qenstatite, Qforsterite, crystallineabs
COMMON GRAINTEMPDATA, tgrain, agrain, olivine_emit, pyroxene_emit, forsterite_emit, enstatite_emit, effectiveTempArray, stellar_emit

; Rename parameters
link=[p[0],p[1],10^(p[2]),p[3],p[4],p[5],p[6],p[7],10^(p[8]),p[9],p[10],p[11]]

; Model spectrum with current parameter values
spectra = modeltwograin(transpose([extra.wave,71.42]),link ) ; changed from spectra1 to spectra

; Separate MIPS from IRS
;mips70 = spectra1[n_elements(extra.wave)]
;spectra= spectra1[0:n_elements(extra.wave)-1]

; *************************************************** ;
; Compute chisq without MIPS
chisq = TOTAL ( ((extra.spec-spectra)^2.0)/((.05*extra.error)^2.0+(extra.error)^2.0))

; Compute chisq with MIPS
;if (extra.mips70_val gt 0) then begin
;  if (mips70 le extra.mips70_val) then begin
;    z = (chisq)/(extra.dof)   ; Log of likelihood func - where likelihood funct is exp(-chisq/2 )                                     
;  endif else begin
;    chisq2 = ((extra.mips70_val-mips70)^2.0)/((extra.mips70_error)^2.0)
;    z = (chisq+chisq2)/(extra.dof) ; Log of likelihood func - where likelihood funct is exp(-chisq/2 )                                
;  endelse
  
; Compute likelihood function
;endif else begin
    z = (chisq)/(extra.dof - 1.)   ; Log of likelihood func - where likelihood funct is exp(-chisq/2 )                                
;endelse
 
; Print to txt file if desired
;openw, 1, 'output_v1/'+extra.name+'_fit_multi_pso.txt',/append
;printf,1,'param,',strtrim(string(p[0]),2),',',strtrim(string(p[1]),2),',',strtrim(string(p[2]),2),',',strtrim(string(p[3]),2),',',strt;rim(string(p[4]),2),',',strtrim(string(p[5]),2),',',strtrim(string(p[6]),2),',',strtrim(string(p[7]),2),',',strtrim(string(p[8]),2),',',strtrim(string(p[9]),2),',',strtrim(string(p[10]),2),',',strtrim(string(p[11]),2),',',strtrim(string(z),2)
;close,1

; Return likelihood and exit
return,z
end


; ****************************************************************************************************** ;
pro pso_test_iterproc,  func, p, iter, interrupt, functargs = functargs, oref = opso, _Extra = extra
; ****************************************************************************************************** ;


compile_opt hidden,idl2
opso->get_property,fresult=fresult

; Write current PSO result to txt file
openw, 1, 'output_v2/'+functargs.name+'_fit_multi_pso_best_'+strtrim(fix(functargs.sequence),2)+'.txt',/append
writeu,1,'Iteration: '+strtrim(string(iter),2)
writeu,1,'fresult : ',fresult

; Write current parameter values to same txt file
for i = 0,n_elements(p)-1 do begin
  strout = 'p['+strtrim(string(i),2)+']='+strtrim(string(p[i]),2)
  writeu,1,strout
endfor

close,1 ; close file
end


; ****************************************************************************************************** ;
pro pso_min_example_m,amin=amin,Teff=teff_val,name=name1,output=output1,out_par=functargs,sequence=sequence
; ****************************************************************************************************** ;


; Uses files listed above such as LINSPACE, F1_EVAL,
; F1_PLOT, PSO_TEST_CONVERT, PSO_TEST_ITERPROC

; Range of the two parameters
prange = [[30.0, 300.0],[amin, 30.0],[16.5, 23.5],[0., 1.0],[0., 1.0],[0., 1.0],$
         [100.0, 1000.0],[amin, 30.0],[16.5, 23.5],[0., 1.0],[0., 1.0],[0., 1.0]]

func = 'f1_eval' ; Function to be minimized
n = 40 ; Number of agents in the swarm

; *************************************************** ;
; Store data 

restore,'savfiles_MIPS_SED/'+name1+'.sav'

err_chk=where( final_specerr le .01*final_spec)
final_specerr(err_chk)=.01*final_spec[err_chk]
;data_base=[transpose(final_wave),transpose(final_spec),transpose(final_specerr)]
dof=n_elements(final_wave)-n_elements(prange(0,*)); + 1.0  ; Added 1 to account for the extra degree due to mips70

functargs =  {  wave:final_wave,    $
                spec:final_spec,    $
                error:final_specerr,$
                dof:dof,            $
                name:name1,         $
                sequence: sequence }

; Store desired outcome (i.e. actual spectrum)
 data_base=[transpose(final_wave),transpose(final_spec),transpose(final_specerr)]
 fxhmake,header1,data_base,/date
 header_lines = strarr(2)
 header_lines[0] = '/  PSO Fit -  Dust Model - Jang Condell et al. 2013, Mittal et al. 2013'
 header_lines[1] = '/  Spitzer IRS spectrum, Chen et al. 2013'
 sxaddhist, header_lines,header1
 file='output_v2/'+name1+'_chn_pso_multi_part_'+strtrim(fix(sequence),1)+'.fits'
 FITS_WRITE,file,data_base,header1
 undefine,data_base;

; *************************************************** ;
; Restore silicate features data                                              

; Find the right grain model for calculating temperatures
Teff=teff_val
effectiveTemp = Teff

cmd = 'ls modelgrids/Teff*grains.sav'
spawn, cmd, grainfiles

; read in temperatures                                                                                                     
strbeg = strpos(grainfiles, 'Teff')+3
strend = strpos(grainfiles, 'grains')
tarray = fltarr(n_elements(grainfiles))
for i=0,n_elements(tarray)-1 do begin
   tarray[i] = float(strmid(grainfiles[i], strbeg[i]+1, strend[i]-strbeg[i]-1))
endfor

; reorder arrays                                                                                               
ii = sort(tarray)
grainfiles = grainfiles[ii]
tarray = tarray[ii]

kuruczindex = interpol(findgen(n_elements(tarray)),tarray,effectiveTemp)
ki = round(kuruczindex) < (n_elements(tarray)-1) > 0
; next command will retrieve temptable, folivine, Teff                                                         
; as generated in generateallgrid.pro                                                                   
; folivine = [0.0, 1.0]                                             
restore, grainfiles[ki]

; *************************************************** ;

; Create global variables relating to silicate features
COMMON grainprops, Qastrosil, Qolivine, Qpyroxene, Qenstatite, Qforsterite, crystallineabs
COMMON GRAINTEMPDATA, tgrain, agrain, olivine_emit, pyroxene_emit, forsterite_emit, enstatite_emit, effectiveTempArray, stellar_emit

; Fill the above global variables
restore, 'graintempdata.sav'
restore, 'qtables_withcrys2.sav' ; qastrosil, qolivine, qpyroxene

 
; Call the PSO minimization routine
p = rmd_pso_m(       ftol = .8,                             $
                     function_name = func,                  $
                     FUNCTARGS = functargs,                 $
                     function_value = fval,                 $
                     ncalls = ncalls,                       $
                     weights = [2.051,2.051],               $
                     itmax = 200,                           $
                     quiet = 0B,                            $
                     iterproc = 'pso_test_iterproc',        $
                     vel_fraction = .5,                     $
                     num_particles = n,                     $
                     vel_decrement = .729,                  $
                     prange = prange                        )

; Rename output and terminate program
output1=[p,fval]
return
end