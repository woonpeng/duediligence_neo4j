Name: {{pipeline.neo4j.servicename}}
Version: 0.2
Release: 1%{?dist}
Summary: This package adds backup and restore capabilities to Neo4j server via SSH

Group: Neo4j Extension Heroes
License: MIT License
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires: openssh openssh-clients neo4j

%description
Neo4j community edition does not have an easy way to backup, restore and purge the database. This package make use of the administration tools on the server and expose this additional functionality via ssh

%install
%{__mkdir_p} %{buildroot}{{pipeline.neo4j.scripts_path}}
%{__cp} %{_sourcedir}/*.sh %{buildroot}{{pipeline.neo4j.scripts_path}}/
%{__mkdir_p} %{buildroot}{{pipeline.neo4j.backup_path}}
%{__mkdir_p} %{buildroot}/etc/sudoers.d
%{__cp} %{_sourcedir}/neo4j-extension.sudoer %{buildroot}/etc/sudoers.d/neo4j-extension

%post
chown root:root /etc/sudoers.d/neo4j-extension

%clean
rm -rf %{buildroot}

%files
%defattr(0755,neo4j,neo4j,0755)
{{pipeline.neo4j.backup_path}}
{{pipeline.neo4j.scripts_path}}/
/etc/sudoers.d/neo4j-extension

%changelog 
*Tue Aug 29 2017 Neo4j Extensions Hereoes 0.2
- Extending Neo4j with backup, restore and purge functionalities via ssh. This is a complete change from v0.1. Also extended with the capability to build a graph database from a zip files of csv
*Thu Jul 20 2017 Neo4j Extensions Hereoes 0.1
- Initial version extending Neo4j with backup, restore and purge functionalities
