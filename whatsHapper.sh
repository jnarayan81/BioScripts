#Phasing with WhatsHap
#Bash script to run it in one GO .... by Jitendra

Green='\033[0;32m' 
Reset='\033[0m'

echo "${Green}Working on Phasing${Reset}"
whatshap phase -o seeWhat.vcf --max-coverage 50 --ignore-read-groups --error-rate=0.15 --maximum-error-rate=0.25 --threshold=100000 --negative-threshold=1000 --merge-reads --indels --reference all_p_ctg.fa see.vcf.gz all_p_ctg.fa.sorted.bam 

echo "${Green}Printing stats${Reset}"
whatshap stats --gtf=seeWhat.gtf seeWhat.vcf

echo "${Green}Runing bgzip${Reset}"
bgzip seeWhat.vcf 

echo "${Green}Tabix running${Reset}"
tabix seeWhat.vcf.gz

echo "${Green}Checking consensus for H1${Reset}" 
bcftools consensus -H 1 -f all_p_ctg.fa seeWhat.vcf.gz > haplo1.fa

echo "${Green}Renaming the fasta headers in H1${Reset}"
perl -pi -e "s/^>/>H1-/g" haplo1.fa

echo "${Green}Checking consensus for H2${Reset}" 
bcftools consensus -H 2 -f all_p_ctg.fa seeWhat.vcf.gz > haplo2.fa

echo "${Green}Renaming the fasta headers in H2${Reset}"
perl -pi -e "s/^>/>H2-/g" haplo2.fa

echo "${Green}Tag-ing the phased reads${Reset}"
whatshap haplotag -o haplotagged.bam --reference all_p_ctg.fa seeWhat.vcf.gz all_p_ctg.fa.sorted.bam

echo "${Green}Running Sibelia${Reset}"
~/Tools/Sibelia-3.0.7-Linux/bin/Sibelia -s fine all_p_ctg.fa all_h_ctg.fa haplo1.fa haplo2.fa

echo "${Green}Ploting circos${Reset}"
/usr/bin/perl ~/Tools/circos-0.69-4/bin/circos -conf circos/circos.conf 
