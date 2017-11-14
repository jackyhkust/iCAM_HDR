# iCAM_HDR
It is an implementation of iCAM-HDR in MatLab in a GUI, based on thw work of
1. https://github.com/cbod/cs766-hdr
2. https://github.com/KAIST-VCLAB/xlrcam
3. www.cis.rit.edu/mcsl/icam06

---------------------------------------------------------------------------------
Instruction:
1. Load LDR image in Testimage
2. Load exposure time text
3. Tool-> Align Image
4. Tool-> Recover HDR Radiance Map
5. Tool->Tone Map (See Description in Powerpoint)
	a. MatLab Built-in
	b. Gamma Compression
	c. Reinhard
	d. Drago
	e. Durand
	f. iCAM06
	g. iCAM02
	h. xlrcam
6. Use Save to save the irradiance Map and Tone-mapped HDR Image