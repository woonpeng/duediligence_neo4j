Name: neo4j-webhook
Version: 0.1
Release: 1%{?dist}
Summary: This package adds backup and restore capabilities to Neo4j server via webhook

Group: Neo4j Extension Heroes
License: MIT License
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Neo4j community edition does not have an easy way to backup, restore and purge the database. This package make use of the administration tools on the server and expose this additional functionality via webhooks

%install
%{__mkdir_p} %{buildroot}/opt/neo4j-webhook
%{__tar} xvzf %{_sourcedir}/webhook-linux-%{_arch}.tar.gz -C %{buildroot}/opt/neo4j-webhook/ --strip-components 1
%{__cp} %{_sourcedir}/*.sh %{buildroot}/opt/neo4j-webhook/
%{__mkdir_p} %{buildroot}/etc/opt/neo4j-webhook
%{__cp} %{_sourcedir}/hooks.json %{buildroot}/etc/opt/neo4j-webhook/
%{__mkdir_p} %{buildroot}/etc/systemd/system/
%{__cp} %{_sourcedir}/neo4j-webhook.service %{buildroot}/etc/systemd/system/
%{__mkdir_p} %{buildroot}/data/backups

%post
ln -s -f /opt/neo4j-webhook/configure-neo4j-webhook.sh %{_bindir}/configure-neo4j-webhook
systemctl daemon-reload
systemctl enable neo4j-webhook
systemctl start neo4j-webhook

%preun
systemctl stop neo4j-webhook
systemctl disable neo4j-webhook

%postun
systemctl daemon-reload

%clean
rm -rf %{buildroot}

%files
%defattr(0755,neo4j,neo4j,0755)
/data/backups
/opt/neo4j-webhook/
/etc/opt/neo4j-webhook/
#/etc/opt/neo4j-webhook/hooks.json
/etc/systemd/system/neo4j-webhook.service
#/etc/opt/neo4j-webhookigure-neo4j-webhook.sh
#/var/lib/neo4j/backup.sh
#/var/lib/neo4j/restore.sh
#/var/lib/neo4j/purge.sh
#/var/lib/neo4j/cleanup.sh
#/var/lib/neo4j/neo4j-webhook.sh
#/var/lib/neo4j/wait-for-db.sh
#/var/lib/neo4j/webhook
#/var/lib/neo4j/gen_hook.sh
#/usr/bin/configure-neo4j-webhook

%changelog 
*Thu Jul 20 2017 Neo4j Extensions Hereoes 0.1
- Initial version extending Neo4j with backup, restore and purge functionalities
