# checkbox-mir
Checkbox tests for the Mir project

## Installation
Install in devmode:
```
sudo snap install --devmode checkbox-mir
```

And make sure that the content interfaces are there:
```
sudo snap connect checkbox-mir:checkbox-runtime checkbox22:checkbox-runtime
sudo snap connect checkbox-mir:provider-resource checkbox22:provider-resource
```

## Launchers
Here are the launchers available:
- `checkbox-mir.mir`:
  This automatically runs the mir-test-tools suites, to be used in CI.

  The operator is responsible to install the mir-test-tools snap along with
  an appropriate GPU userspace provider (graphics-core{20,22}, gpu-2404).

- `checkbox-mir.graphics`:
  This automatically runs the various graphics-test-tools utilities to verify
  the graphics setup on the device under test.

  The operator is responsible to install the graphics stack and connect
  the interfaces, if appropriate (replace 24 with 20 or 22, as appropriate):
  ```
  sudo snap install graphics-test-tools --channel 24/stable
  sudo snap disconnect graphics-test-tools:gpu-2404
  sudo snap disconnect checkbox-mir:gpu-2404
  sudo snap connect graphics-test-tools:gpu-2404 <your-gpu-2404-provider>
  sudo snap connect checkbox-mir:gpu-2404 <your-gpu-2404-provider>

  sudo snap connect graphics-test-tools:wayland checkbox-mir
  sudo snap connect graphics-test-tools:x11 checkbox-mir
  ```

- `checkbox-mir.snaps`:
  This gives you a selection of snaps to test updates of. This is a semi-manual
  suite guiding the operator through the steps required to confirm the updated
  snap is working fine, and what to do with the result.
