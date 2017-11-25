// given two points and starting/ending time get a list of possible routes
public List<Route> calculateRoutes(User user, Position from, Position to, DateTime start, DateTime end) {
    // load the preference profile, the set of vehicles in order of priority and the list of pauses
    PreferenceProfile profile = user.getPreferenceProfile();  // TODO: select a specific profile preference
    Set<TransportMean> availableVehicles = profile.getOrderedTransportSet();
    List<TraavelPause> pauses = profile.getTravelPauses();
    
    List<Route> possibleRoutes = new ArrayList<Route>();
    for (TransportMean tm : availableVehicles) {
        // don't calculate routes on foot or bicycle if too long
        if ((tm instanceof OnFoot || tm instanceof Bicycle) && distance(from, to) > profile.getMaxLengthOnFoot()) {
            continue;
        }
        // don't calculate routes for vehicles which are out of their timeslot
        for (DisableMean forbiddenTimeslot : tm.getForbiddenTimeslots()) {
            if (forbiddenTimeslot.getStart() <= start && forbiddenTimeslot.getEnd() >= start
                || forbiddenTimeslot.getStart() <= end && forbiddenTimeslot.getEnd() >= end
                || forbiddenTimeslot.getStart() >= start && forbiddenTimeslot.getEnd() <= end) {
                continue;
            }
        }
        
        // calculate the route with that vehicle
        // queryRoute returns a route with all necessary data (length, duration, changes, CO2)
        Route possibleRoute = queryRoute(from, to, start, end, tm);
        
        // modify the route according to the given pauses
        for (TravelPause tp : pauses) {
            // if a route part interleaves with a pause, delete it
            for (RoutePart rp : possibleRoute.getRouteParts()) {
                if (rp.getStartTime() <= tp.getStart() && rp.getEndTime() >= tp.getStart()
                    || rp.getStartTime() <= tp.getEnd() && rp.getEndTime() >= tp.getEnd()
                    || rp.getStartTime() >= tp.getStart() && rp.getEndTime() <= tp.getEnd()) {
                    possibleRoute.removePart(rp);
                }
            }
            // if some route parts have been deleted, calculate a new route for that part out of the pause
            for (RoutePart rp : possibleRoute.getRouteParts()) {
                RoutePart next = rp.getNext();
                // detect two disconnected route parts
                if (!rp.getEnd().equals(next.getStart()) ) {
                    // check if you have more time before or after the pause
                    int timeBeforePause = tp.getStart() - rp.getEndTime();
                    int timeAfterPause = next.getStartTime() - tp.getEnd();
                    // add new route with addRoutePart(newRoute, rp1, rp2)
                    if (timeBeforePause > timeAfterPause) {
                        // check if the pause is flexible: in that case there is less constraint on the duration of the route
                        if (tp.isFlexible()) {
                            possibleRoute.addRoutePart(queryRoute(rp.getEnd(), next.getStart(), rp.getEndTime(), tp.getEnd() - tp.getMinimumDuration(), tm), rp, next);
                        } else {
                            possibleRoute.addRoutePart(queryRoute(rp.getEnd(), next.getStart(), rp.getEndTime(), tp.getStart(), tm), rp, next);
                        }
                    } else {
                        if (tp.isFlexible()) { 
                            possibleRoute.addRoutePart(queryRoute(rp.getEnd(), next.getStart(), tp.getStart() + tp.getMinimumDuration(), next.getStartTime(), tm), rp, next);
                        } else {
                            possibleRoute.addRoutePart(queryRoute(rp.getEnd(), next.getStart(), tp.getEnd(), next.getStartTime(), tm), rp, next);
                        }
                    }
                }
            }
        }
        
        // add it to a list
        possibleRoutes.add(possibleRoute);
    }
    
    // find routes that minimize each parameter
    List<Route> finalRoutes = new ArrayList<Route>();
    if (possibleRoutes.size() > 0) {
        Route leastLength = leastDuration = leastChanges = leastCO2 = possibleRoutes.get(0);
        for (Route r : possibleRoutes) {
            if (r.getLength() < leastLength.getLength()) {
                leastLength = r;
            }
            if (r.getDuration() < leastDuration.getDuration()) {
                leastDuration = r;
            }
            if (r.getChanges() < leastChanges.getChanges()) {
                leastChanges = r;
            }
            if (r.getCO2() < leastCO2.getCO2()) {
                leastCO2 = r;
            }
        }
        
        finalRoutes.add(leastLength);
        finalRoutes.add(leastDuration);
        finalRoutes.add(leastChanges);
        finalRoutes.add(leastCO2);
    }
    
    return finalRoutes;
}