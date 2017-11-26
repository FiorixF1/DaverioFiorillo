// inside class Appointment
public void removeAllRoutes(User user) {
    Calendar cal = user.getCalendar();
    
    // remove the route to the appointment
    this.removeRoute(user);
    
    // remove the route starting from the appointment, if one exists
    Set<Route> routesOfTheDay = cal.getRoutes(this.getEndTime().getDay());
    Route toBeRemoved = null;
    for (Route r : routesOfTheDay) {
        if (r.getStart().getPosition().equals(this.getPosition())) {
            toBeRemoved = r;
            break;
        }
    }
    if (toBeRemoved != null) {
        cal.removeRoute(toBeRemoved);
    }
}