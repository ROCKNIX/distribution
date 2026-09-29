ROCKNIX GENERIC_X64 - UTM quick start
=====================================

1. Double-click the .utm file to add the VM to UTM
   (get UTM from https://mac.getutm.app if you don't have it).

2. Start the VM. ROCKNIX boots to the game library.

3. To link cloud storage, open Cloud Setup in ROCKNIX. It shows a
   connection command and a password. In Terminal on this Mac, run the
   command shown on the ROCKNIX screen:

     ssh -L 53682:localhost:53682 -p 10022 root@127.0.0.1

   then run:

     rclone config

   and follow the prompts (new remote, pick your provider; defaults are
   fine). When asked "Use auto config?", answer Y and open the sign-in
   link it prints in this Mac's browser. Quit with 'q' when done, then
   press a button on the ROCKNIX screen - it checks that the remote
   works.

Troubleshooting

- "Connection refused" from ssh: the VM must be running, and the VM's
  network mode must be Emulated VLAN (the shipped default) - UTM does
  not apply port forwards in other NAT modes. If you switch the mode,
  also remove the two -fw_cfg entries under the VM's QEMU > Arguments;
  ROCKNIX then shows the VM's own address instead of this command.
- ssh warns about a changed host key after replacing the VM: run
  ssh-keygen -R "[127.0.0.1]:10022" and connect again.
- The sign-in link never loads: make sure you connected with the full
  command above (the -L part carries the sign-in page to this Mac).
