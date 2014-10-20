NexGenAirlifter
===============

Use range_payload_plot to get a estimated max gross takeoff weight.  Next, use the tw_ws_design plot and find a design point.  Knowing the MTOW and the T/W and W/S design point it is now possible to determine thrust required and wing area required.  Based on your aspect ratio input and this new found wing area you should be able to calculate span and chord manually.

range_payload_plot:

Plots contours that relate max gross takeoff weight to range and payload.  Note, it uses the wftransport function for determining the weight fractions and does not represent the mission profile we planned on...

tw_ws_design:

Plots the wing loading and thrust to weight ratio plot with as many relevant design constraints as possible
