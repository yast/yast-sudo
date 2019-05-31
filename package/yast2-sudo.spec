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

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           yast2-sudo
Summary:        YaST2 - Sudo configuration
Version:        4.1.0
Release:        0
Url:            https://github.com/yast/yast-sudo
Group:          System/YaST
License:        GPL-2.0-only

Source0:        %{name}-%{version}.tar.bz2

Requires:       yast2-users
# Wizard::SetDesktopTitleAndIcon
Requires:       yast2 >= 2.21.22
Requires:       yast2-ruby-bindings >= 1.0.0

BuildRequires:  yast2 yast2-users
BuildRequires:  yast2-devtools >= 3.0.6
BuildRequires:  rubygem(yast-rake)

#ycp::PathComponents
Conflicts:      yast2-core < 2.13.29
#Sudo icons
Conflicts:      yast2_theme < 2.13.9

BuildArch:      noarch

%description
The YaST2 component for sudo configuration. It configures capabilities
of users to run commands as root or other user.

%prep
%setup -n %{name}-%{version}

%check
rake test:unit

%build

%install
%yast_install
%yast_metainfo

%files
%{yast_yncludedir}
%{yast_clientdir}
%{yast_moduledir}
%{yast_desktopdir}
%{yast_metainfodir}
%{yast_scrconfdir}
%{yast_agentdir}
%{yast_icondir}
%doc %{yast_docdir}
%license COPYING

%changelog
