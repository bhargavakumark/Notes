Tech : Shingled Writes
======================

**Shingled write recording** trades
the inconvenience of the inability to update in-place for a much
higher data density by a using a different write technique that
overlaps the currently written track with the previous track.
Random reads are still possible on such devices, but writes must
be done largely sequentially.

However, current disk drives store 400 GB/in2 , and are rapidly approaching
the density limit imposed by the super-paramagnetic effect for
perpendicular recording, estimated to be about 1 Tb/in2

The dramatic improvements in disk data density will even-
tually be limited by the superparamagnetic effect, which
creates a trade-off between the media signal-to-noise ratio,
the writeability of the media by a narrow track head, and the
thermal stability of the medi

A fundamental problem in magnetic recording is the control
of the magnetic field whose flux emanates from the write head
and must return to it without erasing previously written data.
While perpendicular recording allows much more stable mag-
netization of the magnetic grains, it complicates engineering
the magnetic field for writing because the flux has to enter
through the recording media in order to do its desired work,
but also has to return back through it to the head. In order
to protect already stored data, the return flux needs to be
sufficiently diffused, limiting the power that the magnetic field
can have.

Shingled writing addresses this problem by allowing data
in subsequent, but not prior, tracks to be destroyed during
writes. Shingled writing uses a write head that generates an
asymmetric, wider, and much stronger field that fringes in
one lateral direction, but is shielded in the other direction.
Figure 2 shows a larger head writing to track n, as used
by Greaves et al. in their simulations [7]. Because of the
larger pole, the strength of the write field can be increased,
allowing a further reduction of the grain size because the
technique can use a more stable medium. The sharp corner-
edge field brings a narrower erase band towards the previous
track, enabling an increase in the track density. Shingled
writing overlaps tracks written sequentially, leaving effectively
narrower tracks where the once-wider leading track has been
partially overwritten. Reading from the narrower remaining
tracks is straightforward using currently-available read heads.


