//---------------Model Signatures-----

//User
sig User {
	id : Int,
	fixedAppointments : set Appointment
}

//Registered User
sig RegisteredUser extends User{
	username : String,
	password : String,
	email : String,
	Nome: String,
	Cognome : String,
	fixedAdvAppointments : set AdvancedAppointment,
	preferenceProfiles : set PreferenceProfile
}

//Preference Profiles

sig PreferenceProfile {
	preferences : set Preference,
	profileName : String
}
//Preferences (plus Flexible launch and Disabled vehicles) (no preference without preferenceProfile)

abstract sig Preference{}

sig FlexibleLaunch extends Preference{}

sig Priority extends Preference {
	orderedTransportSet : seq TransportMeans
}

abstract sig TimedPreference extends Preference {
	validity  : Period
}

sig DisableMeans extends TimedPreference {
	disabled : TransportMeans
}

sig MaxLengthPreference {
	transportMeans : TransportMeans,
	maxLenght : Int
}

sig TravelPause {}

//Period
sig Period {
	beginHour : Int,
	beginMinute: Int,
	endHour: Int,
	endMinute: Int
}

//Appointment
sig Appointment {
	beginTime : DateTime,
	endTime : DateTime,
	descriprion : String,
	address : Position,
	route : Route
}

//Advance Appointment
sig AdvancedAppointment{
	appliedPreferences : set PreferenceProfile,
	appointment : one Appointment
}
	
//DateTime
sig DateTime {
	month : Int,
	day : Int,
	year : Int,
	hour : Int,
	minute : Int
}

//Route
sig Route {
	steps : some RoutePart
}

//Route Part
sig RoutePart {
	from : Position,
	to : Position,
	startTime : DateTime,
	endTime : DateTime,
	forecast : lone WeatherConditions
}

//Position
sig Position {
	street : String,
	municipality : String,
	number : Int,
	cap : Int,
	coordinates : Coord
}

sig Coord {}

//WeatherCondition
sig WeatherConditions{}

//Transport Means 
sig TransportMeans{}

//---------------Facts Area---------------

//Unique UserID

//Unique Username
//Each appointment linked to a unique person (not non-linked appointments)
//Each route linked to unique appointment (not non-linked route)
//All route Part compose the route (end of a part is the begin of the other (time an position)
//No travel part during Flexible launch
//For each appointment, at least one route

//---------------Predicates---------------

//Register an appointment in the agenda
//User Registration
//Create a preference
//Add a preference to a Profile


//show world
pred show{
<<<<<<< HEAD

}

run show for 1
=======
	

}

run show 
>>>>>>> 1073a6aeb13ef311b4f2eaa0c85818d04d1518f0
