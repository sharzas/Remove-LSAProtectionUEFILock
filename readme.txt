This package will install the "Local Security Authority (LSA) Protected Process Opt-out tool (LSAPPLConfig)"

It adds/activates the required EFI boot loader for removing LSA Protection (RunAsPPL) UEFI variable from 
firmware on UEFI based systems.

IMPORTANT:
This process requires console access. After adding the boot loader the system must be rebooted, and F3 must
be interactively pressed on the keyboard to finalize the removal (opt out) and disable LSA Protection!