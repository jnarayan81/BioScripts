#!/usr/bin/env Rscript

#Script by Jitendra 
#USAGE: Rscript plotChitra.R -l /home/urbe/Tools/MyTools/Chitra/testData/ -f a -o test -n 2

#install.packages('reshape') / ("optparse") / (ggplot2)
library("optparse")
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
  make_option(c("-l", "--location"), type="character", default=NULL, 
              help="folder location", metavar="character"),
  make_option(c("-n", "--name"), type="character", default="defChrName", 
              help="chromosome name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out.txt", 
              help="output file name [default= %default]", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$file)){
  print_help(opt_parser)
  stop("BAM file argument must be supplied (input file).n", call.=FALSE)
} else if (is.null(opt$location)){
  print_help(opt_parser)
  stop("Working location must be supplied (input location).n", call.=FALSE)
} else if (is.null(opt$name)){
  print_help(opt_parser)
  stop("Chromosome name must be supplied (input name).n", call.=FALSE)
}

setwd(opt$location)  # working path
coverage=read.table(opt$file, sep="\t", header=F)
library(reshape)
library(ggplot2)
coverage=rename(coverage,c(V1="Chr", V2="locus", V3="depth", V4="CovRange")) # renames the header
png(filename=opt$out, width=2000, height=600)
ggplot(coverage, aes(x=locus, y=depth, color=CovRange)) +
ggtitle(paste0(opt$name, " ", "Coverage Plot")) + 
theme(plot.title = element_text(hjust=0.5)) + 
geom_point(size=1, shape=20, alpha=1/3) +
scale_y_continuous(trans = scales::log10_trans(), breaks = scales::trans_breaks("log10", function(x) 10^x))
