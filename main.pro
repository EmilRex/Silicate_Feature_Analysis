; ****************************************************************************************************** ;
pro main;,name
; ****************************************************************************************************** ;
; Perform setup operations

; Home directory
home_dir = '~/Summer2014/Silicate_Feature_Analysis/'
CD, home_dir

; Path
!PATH=!PATH+':'+Expand_Path('+'+home_dir)

; Functional directories
COMMON file_path, in_dir, out_dir, fit_name, object_name
in_dir = 'savfiles_MIPS_SED_corrected'
out_dir = '../Silicate_Feature_Analysis_output'

; *************************************************** ;
;For testing diskspectrum
;COMMON disk_benchmarking, run, times, lines
;run = 0
;times = dblarr(8000,11)
;lines = dblarr(8000,8)

; *************************************************** ;
; RUN SINGLE
; *************************************************** ;

;object_name = name
;fit_name = fittype

;define_stellar_params
;fits_v1, object_name, fit_name
;plot_result
;null = display_historic(object_name)
;null = display_results(object_name)


; Select object and fit model
; Remember to comment out bad new data points for new runs
;name = 'HD117214' 
;name = 'HD114082'
;name = 'HD106906'

;fit_name = 'multi_mips' ;
;fit_name = 'single'
;fit_name = 'disk_mips'

; Run program
;fits_v1, name=name, fittype=fit_name
;null = display_results(name)

; Print plot of result
;plot_result, name

; See how well mcmc did
;mcmc_analytics, name

; *************************************************** ;
;RUN MULTIPLE
; *************************************************** ;

names = 'HD114082';['HD95086','HD146897'];['HD146897','HD117214']'HD108257';'HD106906';
fit_names = 'single';['single','multi_mips','disk_mips']

FOREACH name, names DO BEGIN
  FOREACH fit_name, fit_names DO BEGIN
    object_name = name
    ;define_stellar_params
    ;fits_v1, name=name, fittype=fit_name
    plot_result
    null = display_historic(name)
    null = display_results(name)
  ENDFOREACH
ENDFOREACH


end