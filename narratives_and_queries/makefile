TIME=/usr/bin/time -f "\n  real      %E\n  real [s]  %e\n  user [s]  %U\n  sys  [s]  %S\n  mem  [KB] %M\n  avgm [KB] %K"
MODEL=../model-original-wcache.pl

# demonstrate constructive negation using "not"
cn-example1:
	scasp -s0 ./cn1.pl
	
cn-example2:
	scasp -s0 ./cn2.pl


# "simulation" of use cases ####################################################
uc1 uc2 uc3a uc3b uc7a uc7b uc7c:
	scasp -s0 --dcc ${MODEL} ./$@.pl


# "simulation" of exception cases ##############################################
ec1 ec7a ec7b ec7c ec7d ec7e ec7f ec8a ec8b ec8c ec9a ec9b ec9c ec10a ec10b ec10c ec11a ec11b ec11c ec12a ec12b ec12c ec13a ec13b ec13c ec20a ec20b ec20c ec21:
	scasp -s0 --dcc ${MODEL} ./$@.pl


# analysis of overdose #########################################################
overdose-ec13a overdose-ec13b overdose-ec13c:
	scasp -s0 --dcc ${MODEL} ./$@.pl
overdose-ec13a-fixed:
	scasp -s0 --dcc ../model-fixed-wcache.pl ./overdose-ec13a.pl
overdose-ec13b-nomaxdose:
	scasp -s0 --dcc ../model-nomaxdose-wcache.pl ./overdose-ec13b.pl
overdose-ec13c-nomaxdose:
	scasp -s0 --dcc ../model-nomaxdose-wcache.pl ./overdose-ec13c.pl


# analysis of overdose using abduction #########################################
overdose-uc2-abduction:
	@mkdir ./output 2> /dev/null || true
	./incremental_abduction.sh ../model-original.pl abducible_initiallyP_vtbi_hard_limit_V_P "" ./overdose-uc2-abduction.pl
overdose-uc2-abduction-fixed:
	@mkdir ./output 2> /dev/null || true
	./incremental_abduction.sh ../model-fixed.pl abducible_initiallyP_vtbi_hard_limit_V_P "" ./overdose-uc2-abduction.pl


# drug reservoir reasoning #####################################################
empty_reserv-uc2-full_reasoning:
	scasp -s0 --dcc ${MODEL} ./empty_reserv-uc2-onerun.pl
empty_reserv-uc2-3run_reasoning:
	./three_runs.sh . empty_reserv-uc2 ${MODEL}


# onetime checking of initial values of fluents ################################
check-narratives:
	scasp -s0 --dcc ${MODEL} ./uc1.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./uc2.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./uc3a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./uc3b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./uc7a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./uc7b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./uc7c.pl ./check_narrative.pl

	scasp -s0 --dcc ${MODEL} ./ec1.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec7a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec7b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec7c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec7d.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec7e.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec7f.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec8a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec8b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec8c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec9a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec9b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec9c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec10a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec10b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec10c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec11a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec11b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec11c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec12a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec12b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec12c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec13a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec13b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec13c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec20a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec20b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec20c.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./ec21.pl ./check_narrative.pl
	
	scasp -s0 --dcc ${MODEL} ./overdose-ec13a.pl ./check_narrative.pl
	scasp -s0 --dcc ../model-fixed-wcache.pl ./overdose-ec13a.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./overdose-ec13b.pl ./check_narrative.pl
	scasp -s0 --dcc ../model-nomaxdose-wcache.pl ./overdose-ec13b.pl ./check_narrative.pl
	scasp -s0 --dcc ${MODEL} ./overdose-ec13c.pl ./check_narrative.pl
	scasp -s0 --dcc ../model-nomaxdose-wcache.pl ./overdose-ec13c.pl ./check_narrative.pl

	scasp -s0 --dcc ${MODEL} ./empty_reserv-uc2-onerun.pl ./check_narrative.pl