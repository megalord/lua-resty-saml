VERSION=0.1

# Default locations
LIBXML2_INCDIR=/usr/include/libxml2
XMLSEC1_INCDIR=/usr/local/include/xmlsec1
XMLSEC1_LIBDIR=/usr/local/lib

CC=gcc
CFLAGS=-g -fPIC
XMLSEC1_CFLAGS=$(shell xmlsec1-config --cflags --crypto=openssl)
CFLAGS_ALL=$(CFLAGS) -Wall -Werror -std=c99 -I$(LIBXML2_INCDIR) -I$(XMLSEC1_INCDIR) $(XMLSEC1_CFLAGS)
LIBFLAG=-shared
LDFLAGS=-g
XMLSEC1_LDFLAGS=$(shell xmlsec1-config --libs --crypto=openssl)
LDFLAGS_ALL=$(LIBFLAG) $(LDFLAGS) -L$(LIBXML2_LIBDIR) -L$(XMLSEC1_LIBDIR) $(XMLSEC1_LDFLAGS)

saml.o: saml.c
	$(CC) -c $(CFLAGS_ALL) -o $@ $<

src/saml.o:
	$(MAKE) -C src saml.o
