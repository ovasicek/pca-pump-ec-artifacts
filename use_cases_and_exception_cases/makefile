TIME=/usr/bin/time -f "\n  real      %E\n  real [s]  %e\n  user [s]  %U\n  sys  [s]  %S\n  mem  [KB] %M\n  avgm [KB] %K"
MODEL=../model-original-wcache.pl

# demonstrate constructive negation using "not"
cn-example1:
	${TIME} scasp -s0 ./cn1.pl
	
cn-example2:
	${TIME} scasp -s0 ./cn2.pl


# "simulation" of use cases ####################################################
uc1:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

uc2:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

uc3a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
uc3b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

uc7a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
uc7b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
uc7c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl


	
# "simulation" of exception cases ##############################################
ec1:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

ec7a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec7b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec7c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec7d:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec7e:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec7f:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

ec8a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec8b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec8c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

ec9a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec9b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec9c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
	
ec10a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec10b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec10c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

ec11a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec11b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec11c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
	
ec12a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec12b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec12c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
	
ec13a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec13b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec13c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl

ec20a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec20b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
ec20c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
	
ec21:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl



# analysis of overdose #########################################################
overdose-ec13a:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
overdose-ec13a-fixed:
	${TIME} scasp -s0 --dcc ../model-fixed-wcache.pl ./overdose-ec13a.pl
overdose-ec13b:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
overdose-ec13b-nomaxdose:
	${TIME} scasp -s0 --dcc ../model-nomaxdose-wcache.pl ./overdose-ec13b.pl
overdose-ec13c:
	${TIME} scasp -s0 --dcc ${MODEL} ./$@.pl
overdose-ec13c-nomaxdose:
	${TIME} scasp -s0 --dcc ../model-nomaxdose-wcache.pl ./overdose-ec13c.pl


# analysis of overdose using abduction #########################################
overdose-uc2-abduction:
	@mkdir ./output 2> /dev/null || true
	{ ${TIME} ./incremental_abduction/incremental_abduction.sh ../model-original.pl abducible_initiallyP_vtbi_hard_limit_V_P "" ./overdose-uc2-abduction.pl 2>&1 ; } | tee output/output-original-stdout.log
overdose-uc2-abduction-fixed:
	@mkdir ./output 2> /dev/null || true
	{ ${TIME} ./incremental_abduction/incremental_abduction.sh ../model-fixed.pl abducible_initiallyP_vtbi_hard_limit_V_P "" ./overdose-uc2-abduction.pl 2>&1 ; } | tee output/output-fixed-stdout.log