
<%
    from pwnlib.shellcraft.thumb.linux import syscall
%>
<%page args="ruid, euid, suid"/>
<%docstring>
Invokes the syscall setresuid.  See 'man 2 setresuid' for more information.

Arguments:
    ruid(uid_t): ruid
    euid(uid_t): euid
    suid(uid_t): suid
</%docstring>

    ${syscall('SYS_setresuid', ruid, euid, suid)}
