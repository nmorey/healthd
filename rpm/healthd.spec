#
# spec file for package healthd
#
# Copyright (c) 2021 SUSE LLC
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


%define         git_ver %{nil}

Name:           healthd
Version:        0.4.0
Release:        0
Summary:        Server monitoring and alert daemons
License:        GPL-3.0-only
Group:          Productivity/Multimedia/Other
BuildArch:      noarch
URL:            https://github.com/nmorey/healthd
Source:         %{name}-%{version}%{git_ver}.tar.gz
Requires(pre):  %fillup_prereq
Requires:       sensors
Requires:       net-tools
Requires:       rrdtool
Requires:       sed
Requires:       smartmontools
Requires:       sysstat

%description
Server monitoring and alert daemon.
- Monitors CPU usage, free memory, disk and service status.
- Generates RRD graph for long term monitoring
- Temperature alter systems for CPU and disks

%prep
%setup -q -n  %{name}-%{version}%{git_ver}

%define dir_flags PREFIX=%{_prefix} BINDIR=%{_bindir} LIBEXEC=%{_libexecdir} SYSCONF_TPL_DIR=%{_fillupdir} SHAREDIR=%{_datarootdir} SYSTEMD=%{_unitdir} SHAREDSTATEDIR=%{_sharedstatedir}

%build
make all %{dir_flags}

%install
%make_install %{dir_flags}

%pre
%service_add_pre healthd-alert.service
%service_add_pre healthd-monitor.service
%service_add_pre healthd-graph.service
%service_add_pre healthd-graph.timer

%preun
%service_del_preun healthd-alert.service
%service_del_preun healthd-monitor.service
%service_del_preun healthd-graph.service
%service_del_preun healthd-graph.timer

%post
%service_add_post healthd-alert.service
%service_add_post healthd-monitor.service
%service_add_post healthd-graph.service
%service_add_post healthd-graph.timer
%{fillup_only -n healthd}

%postun
%service_del_postun healthd-alert.service
%service_del_postun healthd-monitor.service
%service_del_postun healthd-graph.service
%service_del_postun healthd-graph.timer


%files
%defattr(-,root,root,-)
%license LICENSE
%doc CHANGELOG
%{_bindir}/*
%{_libexecdir}/%{name}
%{_unitdir}/*
%{_fillupdir}/sysconfig.%{name}
%{_datarootdir}/%{name}/
%dir %{_sharedstatedir}/%{name}
%dir %{_sharedstatedir}/%{name}/html
%dir %{_sharedstatedir}/%{name}/rrd

%changelog
