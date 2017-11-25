public boolean checkOverlapping(Calendar cal, Appointment app, DateTime begin, DateTime end) {
    // check if the user is free during the timeslot begin-end
    Set<Appointment> appsBefore = cal.getAppointments(begin.getDay());  // get appointments in the same day of the starting time
    Set<Route> routesBefore = cal.getRoutes(begin.getDay());            // get routes in the same day of the starting time
    Set<Appointment> appsAfter = cal.getAppointments(end.getDay());     // get appointments in the same day of the ending time
    Set<Route> routesAfter = cal.getRoutes(end.getDay());               // get routes in the same day of the ending time
    
    // special case for routes: app-route CAN overlap with its own appointment because it just raises a warning
    appsBefore.remove(app);
    appsAfter.remove(app);
    
    // always check events starting and ending during the timeslot
    
    // appointments overlapping with the starting time
    for (Appointment app : appsBefore) {
        if (app.beginTime < begin && app.endTime > begin || app.beginTime >= begin && app.endTime <= end) {
            return false;
        }
    }
    
    // routes overlapping with the starting time
    for (Route route : routesBefore) {
        if (route.beginTime < begin && route.endTime > begin || route.beginTime >= begin && route.endTime <= end) {
            return false;
        }
    }
    
    // appointments overlapping with the ending time
    for (Appointment app : appsAfter) {
        if (app.beginTime < end && app.endTime > end || app.beginTime >= begin && app.endTime <= end) {
            return false;
        }
    }
    
    // routes overlapping with the ending time
    for (Route route : routesAfter) {
        if (route.beginTime < end && route.endTime > end || route.beginTime >= begin && route.endTime <= end) {
            return false;
        }
    }
    
    return true;
}