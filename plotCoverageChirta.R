#!/usr/bin/env Rscript

#Script by Jitendra 
#Need to generate coverage file using -a flag in samtools
#samtools depth -a in.bam > in.coverage
#samtools faidx ref.fa
#sort -k2,2 -nr ref.fa.fai|cut -f1,2 > scaffolds.size

#USAGE: Rscript plotCoverageChirta.R -f testData/bam.coverage -s testData/scaffolds.size -o see 

#install.packages("optparse") / (ggplot2)
library("optparse")
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="coverage file name", metavar="character"),
  make_option(c("-s", "--size"), type="character", default=NULL, 
              help="size file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out.txt", 
              help="output file name [default= %default]", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$file)){
  print_help(opt_parser)
  stop("Samtools depth coverage file argument must be supplied (input file).n", call.=FALSE)
} else if (is.null(opt$size)){
  print_help(opt_parser)
  stop("Scaffold sizes argument must be supplied (input file).n", call.=FALSE)
}

library('ggplot2')
#Plot the coverage
coverage <- read.delim(opt$file, header=FALSE)
#svg(filename=opt$out)
ggplot(coverage, aes(x=coverage$V3, y = ..count.. )) + geom_density(fill="antiquewhite3", alpha=0.4) + labs(x='coverage', y = '') + xlim(0,500)

#Plot the aggregate sizes
sizes <- read.delim(opt$size, header=FALSE)
result <- aggregate(coverage$V3, list(Scaffold = coverage$V1), mean) #depth mean per scaffold
rm(coverage)
names(sizes)=c("Scaffold", "length")
combined <- merge(result, sizes, by="Scaffold")
plot(combined$length, combined$x)
ggplot(combined, aes(x=combined$length, y=combined$x)) + geom_point() + labs( x ="length",y = "mean coverage")

dev.off()
