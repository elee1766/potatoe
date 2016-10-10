import random
f = open('potatoe.txt','r')

quoteL = []

for line in f:
    quoteL.append(line.rstrip()),

toread = random.randint(0,len(quoteL)) - 1

print(quoteL[toread])
