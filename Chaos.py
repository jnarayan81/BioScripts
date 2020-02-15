#!/usr/bin/python
# Author: Jitendra jnarayan81@gmail.com

import collections
from collections import OrderedDict
from matplotlib import pyplot as plt
from matplotlib import cm
import pylab
import math

import sys, argparse

# construct the argument parser and parse the arguments
#parser.add_argument('-f', type=float)
#parser.add_argument('--file', type=file)

ap = argparse.ArgumentParser()
ap.add_argument("-i", "--input", required=True,
	help="path to input FASTA")
ap.add_argument("-k", "--kmer", required=True, type=int,
	help="path to input KMER")
ap.add_argument("-o", "--output", required=True,
	help="path to output PNG")
args = vars(ap.parse_args())


f = open(args["input"])
s1 = f.read()
data = "".join(s1.split("\n")[1:])
 
def count_kmers(sequence, k):
    d = collections.defaultdict(int)
    for i in xrange(len(data)-(k-1)):
        d[sequence[i:i+k]] +=1
    for key in d.keys():
        if "N" in key:
            del d[key]
    return d
 
def probabilities(kmer_count, k):
    probabilities = collections.defaultdict(float)
    N = len(data)
    for key, value in kmer_count.items():
        probabilities[key] = float(value) / (N - k + 1)
    return probabilities
 
def chaos_game_representation(probabilities, k):
    array_size = int(math.sqrt(4**k))
    chaos = []
    for i in range(array_size):
        chaos.append([0]*array_size)
 
    maxx = array_size
    maxy = array_size
    posx = 1
    posy = 1
    for key, value in probabilities.items():
        for char in key:
            if char == "T":
                posx += maxx / 2
            elif char == "C":
                posy += maxy / 2
            elif char == "G":
                posx += maxx / 2
                posy += maxy / 2
            maxx = maxx / 2
            maxy /= 2
        chaos[posy-1][posx-1] = value
        maxx = array_size
        maxy = array_size
        posx = 1
        posy = 1
 
    return chaos
 
kmer=args["kmer"]
fkmer = count_kmers(data, args["kmer"])
fkmer_prob=probabilities(fkmer, args["kmer"]) 

chaos_kkmer = chaos_game_representation(fkmer_prob, args["kmer"])
pylab.title('Chaos game representation for kmer:{0} ' .format(kmer))
pylab.imshow(chaos_kkmer, interpolation='nearest', cmap=cm.gray_r)
#only one is supported either .show or .savefig
#pylab.show()

pylab.savefig(args["output"])
