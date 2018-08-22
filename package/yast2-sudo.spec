#
# spec file for package yast2-sudo
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-sudo
Version:        4.0.0
Release:        0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2

url:            http://github.com/yast/yast-sudo
Group:          System/YaST
License:        GPL-2.0-only
Requires:	yast2-users
# Wizard::SetDesktopTitleAndIcon
Requires: yast2 >= 2.21.22
#ycp::PathComponents
Conflicts: yast2-core < 2.13.29
#Sudo icons
Conflicts: yast2_theme < 2.13.9
BuildRequires:	yast2 yast2-users
BuildRequires:  yast2-devtools >= 3.0.6
BuildRequires:  rubygem(yast-rake)

BuildArchitectures:	noarch

Requires:       yast2-ruby-bindings >= 1.0.0

Summary:	YaST2 - sudo configuration

%description
The YaST2 component for sudo configuration. It configures capabilities
of users to run commands as root or other user.

%prep
%setup -n %{name}-%{version}

%check
rake test:unit

%build

%install
rake install DESTDIR="%{buildroot}"


%files
%defattr(-,root,root)
%dir %{yast_yncludedir}/sudo
%{yast_yncludedir}/sudo/*
%{yast_clientdir}/sudo.rb
%{yast_moduledir}/Sudo.*
%{yast_desktopdir}/sudo.desktop
%{yast_scrconfdir}/sudo.scr
%{yast_agentdir}/ag_etc_sudoers
%doc %{yast_docdir}
