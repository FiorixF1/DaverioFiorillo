//Signatures

sig User {
	id : Int,
	fixedAppointments : set Appointment
}

sig RegisteredUser extends User{
	username : one Username,
	password : one Password,
	email : one Email,
	name: one Name,
	surname : one Surname,
	cf : one CF,
	fixedAdvAppointments : set AdvancedAppointment,
	preferenceProfiles : set PreferenceProfile
}

sig Appointment{
	beginTime : one DateTime,
	endTime : one DateTime,
	description : one string,
	address : Position,
	route :  set Route
}

sig AdvancedAppointment extends Appointment{
	appliedPreferences : set PreferenceProfile,
}

sig Route {
	steps : some RoutePart,
	start : one RoutePart,
	end : one RoutePart
}

sig RoutePart {
	from : Position,
	to : Position,
	startTime : DateTime,
	endTime : DateTime,
	forecast : lone WeatherCondition,
	travelMeans : TravelMeans
}

sig Position {
	street : string,
	municipality : string,
	number : Int,
	cap : CAP,
	coordinates : Coord
}

sig PreferenceProfile{
	preferences : set Preference,
	name : string
}

one sig DefaultProfile extends PreferenceProfile {}



//Other Sig
sig Username{}
sig Password{}
sig Email{}
sig Name{}
sig Surname{}
sig CF {}
sig CAP {}
sig string{}
sig Coord{}
sig WeatherCondition{}
sig Preference {}
sig TravelMeans {}


sig DateTime{
	month : Int,
	day : Int,
	year : Int,
	hour : Int,
	minute : Int
}

//All normal appointment are linked to normal users, AdvancedAppointments to RegisteredUsers
fact AppointmentAndAdvancedAppointment{	
	all a: Appointment, ad: AdvancedAppointment | ((a in (Appointment - AdvancedAppointment)) implies a in User.fixedAppointments) 
		&& ad in RegisteredUser.fixedAdvAppointments
}

//Username, Email, CF for RegisteredUsers are keys
fact uniqueIdUsernameEmailCF{
	all u1, u2 : RegisteredUser | u1 != u2 implies 
		(u1.id != u2.id && u1.username != u2.username && u1.cf != u2.cf && u1.email != u2.email)
}

//There aren't Usernames, Passwords, Email, Name, Surname, CF not linked to anyone
fact noOrphanUsernamePasswordEmailNameSurnameCF{
	all us : Username, c: CF, e : Email, p:Password, n:Name, s:Surname | 
		us in RegisteredUser.username && c in RegisteredUser.cf && e in RegisteredUser.email 
		&& p in RegisteredUser.password && n in RegisteredUser.name && s in RegisteredUser.surname
}

//Constrains on Calendar Data
fact DateTimeCalendarConstrains{
	all dt : DateTime | dt.month <= Int[12] && dt.day <= 31 && dt.hour < 24 && dt.minute <60
		&& dt.month > 0 && dt.day > 0 && dt.hour >= 0 && dt.minute >= 0 
		&& dt.year = 0 //Added to reduce scope and complexity
}

//Coords and WeatherCondition always linked to Position and RoutePart
fact noOrphanWeatherConditionCoord{
	all w: WeatherCondition, c : Coord | c in Position.coordinates && w in RoutePart.forecast
}

//Preferences are always linked to a PreferenceProfile as well as that is always linked to a RegisteredUser
fact PreferenceProfileConstraints{
	all p : Preference | p in PreferenceProfile.preferences
	all pp : PreferenceProfile | pp in RegisteredUser.preferenceProfiles
}

//WeatherCondition are guaranteed to RegisteredUser
fact WeatherConditionForRegisteredUser{
	all adst: AdvancedAppointment.route.(steps+start+end) | adst.forecast != none
}

//Coord are keys for Position
fact uniqueCoords{
	all p1, p2 : Position | p1 != p2 implies p1.coordinates != p2.coordinates
}

//RoutePart are not of null length or equal segments
fact lengthNotNull{
	all rp : RoutePart | rp.from != rp.to
	no disj rp, rp1 : RoutePart | rp.from = rp1.from and rp.to = rp1.to
}

//intemediate steps aren't start or end ones
fact {
	all r : Route | (no s : r.steps | r.start = s or r.end = s)
}

//Route Parts are linked to form a Route
fact {
	all r : Route | (
		(lone s : r.steps | r.start.to = s.from)
		&& (lone s : r.steps | r.end.from = s.to)
		&& (no s : r.steps | r.start.from = s.to)
		&& (no s : r.steps | r.end.to = s.from)
		&& (all s : r.steps | s.to = r.end.from or one s1: r.steps | s.to = s1.from)
		&& (all s : r.steps | s.from = r.start.to or one s1 : r.steps | s.from = s1.to)
		&& (#r.steps = 0 implies (r.start = r.end or r.start.to= r.end.from) else r.start != r.end)
	)
}

pred addRoutePart ( r: Route, rp: RoutePart, r' : Route ){
	//prec
	r.end.to = rp.from
	//postc
	r'.start = r.start and r'.steps= (r.steps+ r.end) and r'.end = rp
}

//A new preference is added to DefaultProfile
pred createPreference(p : Preference, dp : DefaultProfile, dp' : DefaultProfile) {
	//prec
	!(p in dp.preferences)
	//postc
	all op : dp.preferences | op in dp'.preferences && p in dp'.preferences && #op = (#dp'.preferences -1)
}

//Add a preference to a profile (This implies the removal from DefaultProfile if present)
pred addPreference(p : Preference, dp : DefaultProfile, dp' : DefaultProfile, pp : PreferenceProfile, pp' : PreferenceProfile) {
	//prec
	!(p in pp.preferences)
	//postc
	all op : dp.preferences | op != p implies op in dp'.preferences else !(op in dp'.preferences)
	all np : pp.preferences | np in pp'.preferences && p in np
}

//Add preferenceProfile to AdvancedAppointment
pred addPreferenceProfileToAppointment(pp : PreferenceProfile, aa : AdvancedAppointment, aa' : AdvancedAppointment) {
	//prec
	!(pp in aa.appliedPreferences)
	//postc
	all pr : aa.appliedPreferences | pr in aa'.appliedPreferences &&  pp in aa'.appliedPreferences
}

//Add an Appointment to User (AdvancedAppointment <> RegisteredUser)
pred addAppointment(a : Appointment, u : User, u' : User) {
	//prec
	a in AdvancedAppointment iff u in RegisteredUser
	!( a in u.fixedAdvAppointments+u.fixedAdvAppointments)
	//postc
	a in AdvancedAppointment implies (all ad : u.fixedAdvAppointments | ad in u.fixedAdvAppointments && a in u.fixedAdvAppointments)
		else (all ab : u.fixedAppointments | ab in u.fixedAppointments && a in u.fixedAppointments)
}

//Remove an Appointment (AdvancedAppointment <> RegisteredUser)
pred removeAppointment(a : Appointment, u : User, u' : User) {
	//prec
	a in AdvancedAppointment iff u in RegisteredUser
	a in u.fixedAdvAppointments+u.fixedAdvAppointments
	//postc
	a in AdvancedAppointment implies 
		(all ad : u.fixedAdvAppointments | ad != a implies ad in u'.fixedAdvAppointments else !(ad in u'.fixedAdvAppointments))
			else (all ba : u.fixedAppointments | ba != a implies ba in u'.fixedAppointments else !(ba in u'.fixedAppointments))
}

pred show{
	#User =2
	#RegisteredUser=1
	#Appointment=2
	#AdvancedAppointment =1
	#Preference = 1
	#PreferenceProfile = 2
	#Route = 1
	#RoutePart = 3
	#TravelMeans = 1
	#CAP = 1
}

run addRoutePart for 5 but 8 Int
run createPreference for 5 but 8 Int
run addPreference for 5 but 8 Int
run addPreferenceProfileToAppointment for 5 but 8 Int
run addAppointment for 5 but 8 Int
run removeAppointment for 5 but 8 Int

//run show for 5 but 8 Int
