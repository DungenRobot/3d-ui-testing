# My Descent into Madness

Problem: TextEdit seems to not work but all other control nodes work.

Install Project and test with the Meta XR Simulator. Arrow keys to look around and t to "click" (use trigger on controllers). 
If you also test the UI scene itself without XR, you should notice that the TextEdit node behaves properly.

I don't know why this happens, the answer might be in the UI Panel code that sends the input events `3DUI > ui_panel > ui_panel.gd > push_mouse_input (line 112)` 
