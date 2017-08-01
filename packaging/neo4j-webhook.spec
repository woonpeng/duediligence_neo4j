Name: {{WEBHOOK_SERVICE}}
Version: 0.1
Release: 1%{?dist}
Summary: This package adds backup and restore capabilities to Neo4j server via webhook

Group: Neo4j Extension Heroes
License: MIT License
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Neo4j community edition does not have an easy way to backup, restore and purge the database. This package make use of the administration tools on the server and expose this additional functionality via webhooks

%install
%{__mkdir_p} %{buildroot}{{WEBHOOK_INSTALL_PATH}}
%{__tar} xvzf %{_sourcedir}/webhook-linux-%{_arch}.tar.gz -C %{buildroot}{{WEBHOOK_INSTALL_PATH}}/ --strip-components 1
%{__cp} %{_sourcedir}/*.sh %{buildroot}{{WEBHOOK_INSTALL_PATH}}/
%{__mkdir_p} %{buildroot}{{WEBHOOK_CONFIG_PATH}}
%{__cp} %{_sourcedir}/hooks.json %{buildroot}{{WEBHOOK_CONFIG_PATH}}/
%{__mkdir_p} %{buildroot}/etc/systemd/system/
%{__cp} %{_sourcedir}/neo4j-webhook.service %{buildroot}/etc/systemd/system/
%{__mkdir_p} %{buildroot}{{WEBHOOK_BACKUP_PATH}}
%{__mkdir_p} %{buildroot}/etc/sudoers.d
%{__cp} %{_sourcedir}/neo4j-webhook.sudoer %{buildroot}/etc/sudoers.d/neo4j-webhook

%post
chown root:root /etc/sudoers.d/neo4j-webhook
ln -s -f {{WEBHOOK_INSTALL_PATH}}/configure-neo4j-webhook.sh %{_bindir}/configure-neo4j-webhook
systemctl daemon-reload
systemctl enable {{WEBHOOK_SERVICE}}
systemctl start {{WEBHOOK_SERVICE}}

%preun
systemctl stop {{WEBHOOK_SERVICE}}
systemctl disable {{WEBHOOK_SERVICE}}

%postun
systemctl daemon-reload

%clean
rm -rf %{buildroot}

%files
%defattr(0755,neo4j,neo4j,0755)
{{WEBHOOK_BACKUP_PATH}}
{{WEBHOOK_INSTALL_PATH}}/
{{WEBHOOK_CONFIG_PATH}}/
/etc/sudoers.d/neo4j-webhook
/etc/systemd/system/neo4j-webhook.service

%changelog 
*Thu Jul 20 2017 Neo4j Extensions Hereoes 0.1
- Initial version extending Neo4j with backup, restore and purge functionalities
