AC_PREREQ(2.61)
AC_INIT(sqlinstaller, 4.0, soliverr@gmail.com)

dnl
dnl Section: subdirectory in base layouts and NAME PREFIX for all packages
dnl
AC_SUBST(SECTION, 'oradba')
AC_MSG_CHECKING(SECTION)
AC_MSG_RESULT($SECTION)

dnl
dnl Show package identification
dnl
AC_MSG_CHECKING(PACKAGE_STRING)
AC_MSG_RESULT($PACKAGE_STRING)

dnl
dnl Common path  for all oradba packages
dnl

dnl Default prefix
AC_PREFIX_DEFAULT('/usr')
if test "$prefix" != "NONE" ; then
    AC_MSG_CHECKING(prefix)
    AC_MSG_RESULT($prefix)
fi

if test "x$localstatedir" = 'x${prefix}/var' ; then
    dnl AC_MSG_NOTICE("Setting default LOCALSTATEDIR to '/var'")
    AC_SUBST(localstatedir, '/var')
fi
AC_MSG_CHECKING(localstatedir)
AC_MSG_RESULT($localstatedir)

if test "x$libexecdir" = 'x${exec_prefix}/libexec' ; then
    AC_SUBST(libexecdir, '${exec_prefix}/libexec/${SECTION}/${PACKAGE_NAME}')
fi
AC_MSG_CHECKING(libexecdir)
AC_MSG_RESULT($libexecdir)

if test "x$datadir" = 'x${datarootdir}' ; then
    AC_SUBST(datadir, '${datarootdir}/${SECTION}/${PACKAGE_NAME}')
fi
AC_MSG_CHECKING(datadir)
AC_MSG_RESULT($datadir)

if test "x$sysconfdir" = 'x${prefix}/etc' ; then
    AC_SUBST(sysconfdir, '/etc')
fi
AC_MSG_CHECKING(sysconfdir)
AC_MSG_RESULT($sysconfdir)

if test "x$docdir" = 'x${datarootdir}/doc/${PACKAGE_TARNAME}' ; then
    AC_SUBST(docdir, '${datarootdir}/doc/${SECTION}/${PACKAGE_TARNAME}-${PACKAGE_VERSION}')
fi
AC_MSG_CHECKING(docdir)
AC_MSG_RESULT($docdir)


dnl
dnl Additional path for oradba packages
dnl

dnl --with-liblsb
liblsb='/lib/lsb'
AC_MSG_CHECKING(liblsb)
AC_ARG_WITH(liblsb,
[  --with-liblsb=DIR       Directory for system wide functions files [/lib/lsb] ],
[ case "$withval" in
    no)
        AC_MSG_ERROR(Need liblsb)
        ;;
    [[\\/$]]* | ?:[[\\/]]* )
        liblsb="$withval"
        ;;
    yes | *)
        AC_MSG_ERROR([expected an absolute directory name for --with-liblsb: $withval])
        ;;
  esac ]
)
AC_SUBST(liblsb)
AC_MSG_RESULT($liblsb)

dnl --with-logdir
logdir='${localstatedir}/log/oracle/${SECTION}/${PACKAGE_NAME}'
AC_MSG_CHECKING(logdir)
AC_ARG_WITH(logdir,
[  --with-logdir=DIR       Directory for logfiles [LOCALSTATEDIR/log/oracle/SECTION/PACKAGE_NAME] ],
[ case "$withval" in
    no)
        AC_MSG_ERROR(Need logdir)
        ;;
    [[\\/$]]* | ?:[[\\/]]* )
        logdir="$withval"
        ;;
    yes | *)
        AC_MSG_ERROR([expected an absolute directory name for --with-logdir: $withval])
        ;;
  esac ]
)
AC_SUBST(logdir)
AC_MSG_RESULT($logdir)

dnl --with-archivelogdir
archivelogdir='${localstatedir}/log/oracle/archive/${SECTION}/${PACKAGE_NAME}'
AC_MSG_CHECKING(archivelogdir)
AC_ARG_WITH(archivelogdir,
[  --with-archivelogdir=DIR       Directory to keep rotated logfiles [LOCALSTATEDIR/log/oracle/archive/SECTION/PACKAGE_NAME] ],
[ case "$withval" in
    no)
        AC_MSG_ERROR(Need archivelogdir)
        ;;
    [[\\/$]]* | ?:[[\\/]]* )
        archivelogdir="$withval"
        ;;
    yes | *)
        AC_MSG_ERROR([expected an absolute directory name for --with-archivelogdir: $withval])
        ;;
  esac ]
)
AC_SUBST(archivelogdir)
AC_MSG_RESULT($archivelogdir)

dnl --with-confdir
confdir='${sysconfdir}/oracle/${SECTION}'
AC_MSG_CHECKING(confdir)
AC_ARG_WITH(confdir,
[  --with-confdir=DIR      Directory for config files [SYSCONFDIR/oracle/SECTION] ],
[ case "$withval" in
    no)
        AC_MSG_ERROR(Need confdir)
        ;;
    [[\\/$]]* | ?:[[\\/]]* )
        confdir="$withval"
        ;;
    yes | *)
        AC_MSG_ERROR([expected an absolute directory name for --with-confdir: $withval])
        ;;
  esac ]
)
AC_SUBST(confdir)
AC_MSG_RESULT($confdir)

dnl --with-spooldir
spooldir='${localstatedir}/spool/oracle/${SECTION}/${PACKAGE_NAME}'
AC_MSG_CHECKING(spooldir)
AC_ARG_WITH(spooldir,
[  --with-spooldir=DIR     Directory for spool files [LOCALSTATEDIR/spool/oracle/SECTION/PACKAGE_NAME] ],
[ case "$withval" in
    no)
        AC_MSG_ERROR(Need confdir)
        ;;
    [[\\/$]]* | ?:[[\\/]]* )
        spooldir="$withval"
        ;;
    yes | *)
        AC_MSG_ERROR([expected an absolute directory name for --with-spooldir: $withval])
        ;;
  esac ]
)
AC_SUBST(spooldir)
AC_MSG_RESULT($spooldir)

AC_CONFIG_FILES([Makefile logrotate.conf _pkg-functions])
AC_CONFIG_FILES([install.sql uninstall.sql sql/packages/sqlinstaller_def.sql])
AC_OUTPUT([dba_sqlinstaller build_expand.sh])

