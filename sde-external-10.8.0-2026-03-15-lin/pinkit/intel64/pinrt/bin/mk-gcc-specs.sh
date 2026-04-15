incdir=$1
libdir=$2
ldso=$3
longtype=$(echo ${4:= long} | sed 's/ /\\ /g')
cat <<EOF
%rename cpp_options old_cpp_options

*cpp_options:
-D_arch_long=$longtype -nostdinc -isystem $incdir -isystem $incdir/pinos -isystem include%s %(old_cpp_options)

*cc1:
%(cc1_cpu) -D_arch_long=$longtype -nostdinc -isystem $incdir -isystem $incdir/pinos -isystem include%s

*cc1plus:
%(cc1_cpu) -D_arch_long=$longtype -nostdinc -nostdinc++ -isystem $incdir -isystem $incdir/pinos -isystem include%s

*link_libgcc:
-L$libdir -L .%s

*libgcc:
libgcc.a%s %:if-exists(libgcc_eh.a%s)

*startfile:
%{!shared: $libdir/Scrt1.o} $libdir/crti.o crtbeginS.o%s

*endfile:
crtendS.o%s $libdir/crtn.o

*link:
-dynamic-linker $ldso -nostdlib  -lpincrt --eh-frame-hdr %{shared:-shared} %{static:-static} %{rdynamic:-export-dynamic}

*esp_link:


*esp_options:


*esp_cpp_options:


EOF
