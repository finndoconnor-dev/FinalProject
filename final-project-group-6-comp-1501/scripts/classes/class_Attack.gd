extends Node

class_name Attack

#When you add attributes here give them a reasonable default value to avoid null pointer exceptions
var damage : float = 0 #How much damage it deals
var knockbackForce : float = 0 #The force of knockback, if no knockback set to 0
var damagesPlayer : bool = false #If the attack can damage players.
var damagesNPC : bool = true #If the attack can damage NPCs.
var triggerInvulnerability : bool = true #If the attack triggeres immunity frames.
var pierces : bool = false #weather the attack should pierce through enemies, or disapear on hit.
