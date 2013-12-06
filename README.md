Savr
====

Savr is an mac application designed to fetch screensaver photos regularly

DOCUMENTATION
=============

NSUserDefaults key
------------------

* `flux_name + fluxIsActive` : Flux is active or not. Master (if not set, defaults to yes, modifies flux accordingly)
* 'flux_name + lastReloadDate' : last reload date for this flux
* `notification` : User wants to be notified when new images are fetched. Default to yes.
* `lastReloadDate` : Last reload date. Does not matter if nil. 
