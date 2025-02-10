# stub BSD makefile that just calls gmake

.MAKE.MODE+=compat # don't add -J #,# to submake calls

all: .DEFAULT

.DEFAULT:
	# unset MAKELEVEL so gmake doesn't think it's a submake
	@env -u MAKELEVEL gmake ${.TARGETS}
