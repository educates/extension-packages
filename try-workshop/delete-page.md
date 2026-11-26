---
title: Deleting the workshop
---

The workshop keeps running after you close its browser tab. When you have
finished trying the packages, delete it from a terminal on your own
machine, not from the workshop's terminal. Click the command to copy it:

```workshop:copy
text: |-
  @DELETE_COMMAND@
```

`package.sh try` prints the same command after it deploys the workshop.
Under Docker, delete the workshop before running `package.sh try` again,
since every workshop it deploys there takes the same port.
