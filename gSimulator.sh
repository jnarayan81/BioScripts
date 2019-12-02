#perl simuG.pl
#perl simuG.pl -refSeq ./Testing_Example/SGDref.R64-2-1.fa.gz -snp_count 1000 -titv_ratio 2.0 -indel_count 100 -exclude_chr_list ./Testing_Example/excluded_chr_list.yeast.txt$
#perl simuG.pl -refSeq ./Testing_Example/SGDref.R64-2-1.fa.gz -snp_count 1000 -titv_ratio 2.0 -indel_count 100 -exclude_chr_list ./Testing_Example/excluded_chr_list.yeast.txt$

: '
mkdir JitSim_allels

perl simuG.pl -refSeq JitSim/simGenome.fa -snp_count 1000 -titv_ratio 2.0 -indel_count 100  -prefix output_jit_sim1 > step1_command
perl simuG.pl -refSeq output_jit_sim1.simseq.genome.fa -cnv_count 10 -cnv_gain_loss_ratio Inf -duplication_tandem_dispersed_ratio Inf --prefix output_jit_sim2 > step2_command
perl simuG.pl -refseq output_jit_sim2.simseq.genome.fa -inversion_count 5 -prefix output_jit_sim3 > step3_command

mv output_jit* JitSim_allels
mv step*  JitSim_allels
cd JitSim_allels
/home/urbe/Tools/Sibelia-3.0.7-Linux/bin/Sibelia -s fine ../JitSim/simGenome.fa output_jit_sim3.simseq.genome.fa
/usr/bin/perl /home/urbe/Tools/circos-0.69-4/bin/circos -conf circos/circos.conf

cd ..


mkdir JitSim_ohno

perl simuG.pl -refSeq JitSim/simGenome.fa -snp_count 10000 -titv_ratio 2.0 -indel_count 1000  -prefix output_jit_sim1 > step1_command
perl simuG.pl -refSeq output_jit_sim1.simseq.genome.fa -cnv_count 20 -cnv_gain_loss_ratio Inf -duplication_tandem_dispersed_ratio Inf --prefix output_jit_sim2 > step2_command
perl simuG.pl -refseq output_jit_sim2.simseq.genome.fa -inversion_count 50 -prefix output_jit_sim3 > step3_command

mv output_jit* JitSim_ohno
mv step* JiSim_ohno
cd JitSim_ohno
/home/urbe/Tools/Sibelia-3.0.7-Linux/bin/Sibelia -s fine ../JitSim/simGenome.fa output_jit_sim3.simseq.genome.fa
/usr/bin/perl /home/urbe/Tools/circos-0.69-4/bin/circos -conf circos/circos.conf
cd ..

mkdir JitSim_ohno_allels
perl simuG.pl -refSeq JitSim_ohno/output_jit_sim3.simseq.genome.fa -snp_count 1000 -titv_ratio 2.0 -indel_count 100  -prefix output_jit_sim1 > step1_command
perl simuG.pl -refSeq output_jit_sim1.simseq.genome.fa -cnv_count 10 -cnv_gain_loss_ratio Inf -duplication_tandem_dispersed_ratio Inf --prefix output_jit_sim2 > step2_command
perl simuG.pl -refseq output_jit_sim2.simseq.genome.fa -inversion_count 5 -prefix output_jit_sim3 > step3_command

mv output_jit* JitSim_ohno_allels
mv step*  JitSim_ohno_allels
cd JitSim_ohno_allels
/home/urbe/Tools/Sibelia-3.0.7-Linux/bin/Sibelia -s fine ../JitSim_ohno/output_jit_sim3.simseq.genome.fa output_jit_sim3.simseq.genome.fa
/usr/bin/perl /home/urbe/Tools/circos-0.69-4/bin/circos -conf circos/circos.conf


cd ..

'

perl -p -e 's/^(>.*)$/$1-ohno/g' JitSim_ohno/output_jit_sim3.simseq.genome.fa > ohno.fasta
perl -p -e 's/^(>.*)$/$1-ohno-allels/g' JitSim_ohno_allels/output_jit_sim3.simseq.genome.fa > ohno_allels.fasta
perl -p -e 's/^(>.*)$/$1-allels/g' JitSim_allels/output_jit_sim3.simseq.genome.fa > alles.fasta
perl -p -e 's/^(>.*)$/$1-origin/g' JitSim/simGenome.fa > original.fasta

cat alles.fasta | while read L; do  echo $L; read L; echo "$L" | rev | tr "ATGC" "TACG" ; done > alles_REV.fasta
cat ohno_allels.fasta | while read L; do  echo $L; read L; echo "$L" | rev | tr "ATGC" "TACG" ; done > ohno_allels_REV.fasta

rm -rf  ohno_allels.fasta alles.fasta

cat *.fasta > allSim.fa

/home/urbe/Tools/Sibelia-3.0.7-Linux/bin/Sibelia -s fine allSim.fa
/usr/bin/perl /home/urbe/Tools/circos-0.69-4/bin/circos -conf circos/circos.conf

#10269  perl simuG.pl -refSeq output_jit_sim1_ohno.simseq.genome.fa -cnv_count 1000 -cnv_gain_loss_ratio Inf -duplication_tandem_dispersed_ratio Inf --pr

nucmer --maxmatch -p prefix -t 48 -p simOout allSim.fa allSim.fa
python /home/urbe/Tools/pyScaf/DotPrep.py --delta simOout.delta

#Visualize in DOT
