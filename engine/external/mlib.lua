--[[ License
	A math library made in Lua

	Copyright (c) 2015 Davis Claiborne

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software
       in a product, an acknowledgement in the product documentation would be
       appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be
       misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]

-- Local Utility Functions ---------------------- {{{
local unpack = table.unpack or unpack

-- Used to handle variable-argument functions and whether they are passed as func{ table } or func( unpack( table ) )
local function checkInput( ... )
	local input = {}
	if type( ... ) ~= 'table' then input = { ... } else input = ... end
	return input
end

-- Deals with floats / verify false false values. This can happen because of significant figures.
local function checkFuzzy( number1, number2 )
	return ( number1 - .00001 <= number2 and number2 <= number1 + .00001 )
end

-- Remove multiple occurrences from a table.
local function removeDuplicatePairs( tab )
	for index1 = #tab, 1, -1 do
		local first = tab[index1]
		for index2 = #tab, 1, -1 do
			local second = tab[index2]
			if index1 ~= index2 then
				if type( first[1] ) == 'number' and type( second[1] ) == 'number' and type( first[2] ) == 'number' and type( second[2] ) == 'number' then
					if checkFuzzy( first[1], second[1] ) and checkFuzzy( first[2], second[2] ) then
						table.remove( tab, index1 )
					end
				elseif first[1] == second[1] and first[2] == second[2] then
					table.remove( tab, index1 )
				end
			end
		end
	end
	return tab
end


local function removeDuplicates4Points( tab )
    for index1 = #tab, 1, -1 do
        local first = tab[index1]
        for index2 = #tab, 1, -1 do
            local second = tab[index2]
            if index1 ~= index2 then
                if type( first[1] ) ~= type( second[1] ) then return false end
                if type( first[2] ) == 'number' and type( second[2] ) == 'number' and type( first[3] ) == 'number' and type( second[3] ) == 'number' then
                    if checkFuzzy( first[2], second[2] ) and checkFuzzy( first[3], second[3] ) then
                        table.remove( tab, index1 )
                    end
                elseif checkFuzzy( first[1], second[1] ) and checkFuzzy( first[2], second[2] ) and checkFuzzy( first[3], second[3] ) then
                    table.remove( tab, index1 )
                end
            end
        end
    end
    return tab
end


-- Add points to the table.
local function addPoints( tab, x, y )
    tab[#tab + 1] = x
    tab[#tab + 1] = y
end

-- Like removeDuplicatePairs but specifically for numbers in a flat table
local function removeDuplicatePointsFlat( tab )
    for i = #tab, 1 -2 do
        for ii = #tab - 2, 3, -2 do
            if i ~= ii then
                local x1, y1 = tab[i], tab[i + 1]
                local x2, y2 = tab[ii], tab[ii + 1]
                if checkFuzzy( x1, x2 ) and checkFuzzy( y1, y2 ) then
                    table.remove( tab, ii ); table.remove( tab, ii + 1 )
                end
            end
        end
    end
    return tab
end


-- Check if input is actually a number
local function validateNumber( n )
	if type( n ) ~= 'number' then return false
	elseif n ~= n then return false -- nan
	elseif math.abs( n ) == math.huge then return false
	else return true end
end

local function cycle( tab, index ) return tab[( index - 1 ) % #tab + 1] end

local function getGreatestPoint( points, offset )
    offset = offset or 1
    local start = 2 - offset
    local greatest = points[start]
    local least = points[start]
    for i = 2, #points / 2 do
        i = i * 2 - offset
        if points[i] > greatest then
            greatest = points[i]
        end
        if points[i] < least then
            least = points[i]
        end
    end
    return greatest, least
end

local function isWithinBounds( min, num, max )
    return num >= min and num <= max
end

local function distance2( x1, y1, x2, y2 ) -- Faster since it does not use math.sqrt
	local dx, dy = x1 - x2, y1 - y2
	return dx * dx + dy * dy
end -- }}}

-- Points -------------------------------------- {{{
local function rotatePoint( x, y, rotation, ox, oy )
    ox, oy = ox or 0, oy or 0
    return ( x - ox ) * math.cos( rotation ) + ox - ( y - oy ) * math.sin( rotation ), ( x - ox ) * math.sin( rotation ) + ( y - oy ) * math.cos( rotation ) + oy
end

local function scalePoint( x, y, scale, ox, oy )
    ox, oy = ox or 0, oy or 0
    return ( x - ox ) * scale + ox, ( y - oy ) * scale + oy
end

local function polarToCartesian( radius, theta, offsetRadius, offsetTheta )
    local ox, oy = 0, 0
    if offsetRadius and offsetTheta then
        ox, oy = polarToCartesian( offsetRadius, offsetTheta )
    end
    local x = radius * math.cos( theta )
    local y = radius * math.sin( theta )
    return x + ox, y + oy
end

local function cartesianToPolar( x, y, ox, oy )
    x, y = x - ( ox or 0 ), y - ( oy or 0 )
    local theta = math.atan2( y, x )
    -- Convert to absolute angle
    theta = theta > 0 and theta or theta + 2 * math.pi
    local radius = math.sqrt( x ^ 2 + y ^ 2 )
    return radius, theta
end
-- }}}

-- Lines --------------------------------------- {{{
-- Returns the length of a line.
local function getLength( x1, y1, x2, y2 )
	local dx, dy = x1 - x2, y1 - y2
	return math.sqrt( dx * dx + dy * dy )
end

-- Gives the midpoint of a line.
local function getMidpoint( x1, y1, x2, y2 )
	return ( x1 + x2 ) / 2, ( y1 + y2 ) / 2
end

-- Gives the slope of a line.
local function getSlope( x1, y1, x2, y2 )
	if checkFuzzy( x1, x2 ) then return false end -- Technically it's undefined, but this is easier to program.
	return ( y1 - y2 ) / ( x1 - x2 )
end

-- Gives the perpendicular slope of a line.
-- x1, y1, x2, y2
-- slope
local function getPerpendicularSlope( ... )
	local input = checkInput( ... )
	local slope

	if #input ~= 1 then
		slope = getSlope( unpack( input ) )
	else
		slope = unpack( input )
	end

	if not slope then return 0 -- Vertical lines become horizontal.
	elseif checkFuzzy( slope, 0 ) then return false -- Horizontal lines become vertical.
    else return -1 / slope end
end

-- Gives the y-intercept of a line.
-- x1, y1, x2, y2
-- x1, y1, slope
local function getYIntercept( x, y, ... )
	local input = checkInput( ... )
	local slope

	if #input == 1 then
		slope = input[1]
	else
		slope = getSlope( x, y, unpack( input ) )
	end

	if not slope then return x, true end -- This way we have some information on the line.
	return y - slope * x, false
end

-- Gives the intersection of two lines.
-- slope1, slope2, x1, y1, x2, y2
-- slope1, intercept1, slope2, intercept2
-- x1, y1, x2, y2, x3, y3, x4, y4
local function getLineLineIntersection( ... )
	local input = checkInput( ... )
	local x1, y1, x2, y2, x3, y3, x4, y4
	local slope1, intercept1
	local slope2, intercept2
	local x, y

	if #input == 4 then -- Given slope1, intercept1, slope2, intercept2.
		slope1, intercept1, slope2, intercept2 = unpack( input )

		-- Since these are lines, not segments, we can use arbitrary points, such as ( 1, y ), ( 2, y )
		y1 = slope1 and slope1 * 1 + intercept1 or 1
		y2 = slope1 and slope1 * 2 + intercept1 or 2
		y3 = slope2 and slope2 * 1 + intercept2 or 1
		y4 = slope2 and slope2 * 2 + intercept2 or 2
		x1 = slope1 and ( y1 - intercept1 ) / slope1 or intercept1
		x2 = slope1 and ( y2 - intercept1 ) / slope1 or intercept1
		x3 = slope2 and ( y3 - intercept2 ) / slope2 or intercept2
		x4 = slope2 and ( y4 - intercept2 ) / slope2 or intercept2
	elseif #input == 6 then -- Given slope1, intercept1, and 2 points on the other line.
		slope1, intercept1 = input[1], input[2]
		slope2 = getSlope( input[3], input[4], input[5], input[6] )
		intercept2 = getYIntercept( input[3], input[4], input[5], input[6] )

		y1 = slope1 and slope1 * 1 + intercept1 or 1
		y2 = slope1 and slope1 * 2 + intercept1 or 2
		y3 = input[4]
		y4 = input[6]
		x1 = slope1 and ( y1 - intercept1 ) / slope1 or intercept1
		x2 = slope1 and ( y2 - intercept1 ) / slope1 or intercept1
		x3 = input[3]
		x4 = input[5]
	elseif #input == 8 then -- Given 2 points on line 1 and 2 points on line 2.
		slope1 = getSlope( input[1], input[2], input[3], input[4] )
		intercept1 = getYIntercept( input[1], input[2], input[3], input[4] )
		slope2 = getSlope( input[5], input[6], input[7], input[8] )
		intercept2 = getYIntercept( input[5], input[6], input[7], input[8] )

		x1, y1, x2, y2, x3, y3, x4, y4 = unpack( input )
	end

	if not slope1 and not slope2 then -- Both are vertical lines
		if x1 == x3 then -- Have to have the same x positions to intersect
			return true
		else
			return false
		end
	elseif not slope1 then -- First is vertical
		x = x1 -- They have to meet at this x, since it is this line's only x
		y = slope2 and slope2 * x + intercept2 or 1
	elseif not slope2 then -- Second is vertical
		x = x3 -- Vice-Versa
		y = slope1 * x + intercept1
	elseif checkFuzzy( slope1, slope2 ) then -- Parallel (not vertical)
		if checkFuzzy( intercept1, intercept2 ) then -- Same intercept
			return true
		else
			return false
		end
	else -- Regular lines
		x = ( -intercept1 + intercept2 ) / ( slope1 - slope2 )
		y = slope1 * x + intercept1
	end

	return x, y
end

-- Gives the closest point on a line to a point.
-- perpendicularX, perpendicularY, x1, y1, x2, y2
-- perpendicularX, perpendicularY, slope, intercept
local function getClosestPoint( perpendicularX, perpendicularY, ... )
	local input = checkInput( ... )
	local x, y, x1, y1, x2, y2, slope, intercept

	if #input == 4 then -- Given perpendicularX, perpendicularY, x1, y1, x2, y2
		x1, y1, x2, y2 = unpack( input )
		slope = getSlope( x1, y1, x2, y2 )
		intercept = getYIntercept( x1, y1, x2, y2 )
	elseif #input == 2 then -- Given perpendicularX, perpendicularY, slope, intercept
		slope, intercept = unpack( input )
        x1, y1 = 1, slope and slope * 1 + intercept or 1 -- Need x1 and y1 in case of vertical/horizontal lines.
	end

	if not slope then -- Vertical line
		x, y = x1, perpendicularY -- Closest point is always perpendicular.
	elseif checkFuzzy( slope, 0 ) then -- Horizontal line
		x, y = perpendicularX, y1
	else
		local perpendicularSlope = getPerpendicularSlope( slope )
		local perpendicularIntercept = getYIntercept( perpendicularX, perpendicularY, perpendicularSlope )
		x, y = getLineLineIntersection( slope, intercept, perpendicularSlope, perpendicularIntercept )
	end

	return x, y
end

-- Gives the intersection of a line and a line segment.
-- x1, y1, x2, y2, x3, y3, x4, y4
-- x1, y1, x2, y2, slope, intercept
local function getLineSegmentIntersection( x1, y1, x2, y2, ... )
	local input = checkInput( ... )

	local slope1, intercept1, x, y, lineX1, lineY1, lineX2, lineY2
	local slope2, intercept2 = getSlope( x1, y1, x2, y2 ), getYIntercept( x1, y1, x2, y2 )

	if #input == 2 then -- Given slope, intercept
		slope1, intercept1 = input[1], input[2]
        lineX1, lineY1 = 1, slope1 and slope1 + intercept1
        lineX2, lineY2 = 2, slope1 and slope1 * 2 + intercept1
	else -- Given x3, y3, x4, y4
        lineX1, lineY1, lineX2, lineY2 = unpack( input )
		slope1 = getSlope( unpack( input ) )
		intercept1 = getYIntercept( unpack( input ) )
	end

	if not slope1 and not slope2 then -- Vertical lines
		if checkFuzzy( x1, lineX1 ) then
			return x1, y1, x2, y2
		else
			return false
		end
	elseif not slope1 then -- slope1 is vertical
		x, y = input[1], slope2 * input[1] + intercept2
	elseif not slope2 then -- slope2 is vertical
		x, y = x1, slope1 * x1 + intercept1
	else
		x, y = getLineLineIntersection( slope1, intercept1, slope2, intercept2 )
	end

	local length1, length2, distance
	if x == true then -- Lines are collinear.
		return x1, y1, x2, y2
	elseif x then -- There is an intersection
		length1, length2 = getLength( x1, y1, x, y ), getLength( x2, y2, x, y )
		distance = getLength( x1, y1, x2, y2 )
	else -- Lines are parallel but not collinear.
		if checkFuzzy( intercept1, intercept2 ) then
			return x1, y1, x2, y2
		else
			return false
		end
	end

	if length1 <= distance and length2 <= distance then return x, y else return false end
end

-- Checks if a point is on a line.
-- Does not support the format using slope because vertical lines would be impossible to check.
local function checkLinePoint( x, y, x1, y1, x2, y2 )
	local m = getSlope( x1, y1, x2, y2 )
	local b = getYIntercept( x1, y1, m )

	if not m then -- Vertical
		return checkFuzzy( x, x1 )
	end
	return checkFuzzy( y, m * x + b )
end -- }}}

-- Segment -------------------------------------- {{{
-- Gives the perpendicular bisector of a line.
local function getPerpendicularBisector( x1, y1, x2, y2 )
	local slope = getSlope( x1, y1, x2, y2 )
	local midpointX, midpointY = getMidpoint( x1, y1, x2, y2 )
	return midpointX, midpointY, getPerpendicularSlope( slope )
end

-- Gives whether or not a point lies on a line segment.
local function checkSegmentPoint( px, py, x1, y1, x2, y2 )
	-- Explanation around 5:20: https://www.youtube.com/watch?v=A86COO8KC58
	local x = checkLinePoint( px, py, x1, y1, x2, y2 )
	if not x then return false end

	local lengthX = x2 - x1
	local lengthY = y2 - y1

	if checkFuzzy( lengthX, 0 ) then -- Vertical line
		if checkFuzzy( px, x1 ) then
			local low, high
			if y1 > y2 then low = y2; high = y1
			else low = y1; high = y2 end

			if py >= low and py <= high then return true
			else return false end
		else
			return false
		end
	elseif checkFuzzy( lengthY, 0 ) then -- Horizontal line
		if checkFuzzy( py, y1 ) then
			local low, high
			if x1 > x2 then low = x2; high = x1
			else low = x1; high = x2 end

			if px >= low and px <= high then return true
			else return false end
		else
			return false
		end
	end

	local distanceToPointX = ( px - x1 )
	local distanceToPointY = ( py - y1 )
	local scaleX = distanceToPointX / lengthX
	local scaleY = distanceToPointY / lengthY

	if ( scaleX >= 0 and scaleX <= 1 ) and ( scaleY >= 0 and scaleY <= 1 ) then -- Intersection
		return true
	end
	return false
end

-- Gives the point of intersection between two line segments.
local function getSegmentSegmentIntersection( x1, y1, x2, y2, x3, y3, x4, y4 )
	local slope1, intercept1 = getSlope( x1, y1, x2, y2 ), getYIntercept( x1, y1, x2, y2 )
	local slope2, intercept2 = getSlope( x3, y3, x4, y4 ), getYIntercept( x3, y3, x4, y4 )

	if ( ( slope1 and slope2 ) and checkFuzzy( slope1, slope2 ) ) or ( not slope1 and not slope2 ) then -- Parallel lines
		if checkFuzzy( intercept1, intercept2 ) then -- The same lines, possibly in different points.
			local points = {}
			if checkSegmentPoint( x1, y1, x3, y3, x4, y4 ) then addPoints( points, x1, y1 ) end
			if checkSegmentPoint( x2, y2, x3, y3, x4, y4 ) then addPoints( points, x2, y2 ) end
			if checkSegmentPoint( x3, y3, x1, y1, x2, y2 ) then addPoints( points, x3, y3 ) end
			if checkSegmentPoint( x4, y4, x1, y1, x2, y2 ) then addPoints( points, x4, y4 ) end

			points = removeDuplicatePointsFlat( points )
			if #points == 0 then return false end
			return unpack( points )
		else
			return false
		end
	end

	local x, y = getLineLineIntersection( x1, y1, x2, y2, x3, y3, x4, y4 )
	if x and checkSegmentPoint( x, y, x1, y1, x2, y2 ) and checkSegmentPoint( x, y, x3, y3, x4, y4 ) then
		return x, y
	end
	return false
end -- }}}

-- Math ----------------------------------------- {{{
-- Get the root of a number (i.e. the 2nd (square) root of 4 is 2)
local function getRoot( number, root )
	return number ^ ( 1 / root )
end

-- Checks if a number is prime.
local function isPrime( number )
	if number < 2 then return false end

	for i = 2, math.sqrt( number ) do
		if number % i == 0 then
			return false
		end
	end
	return true
end

-- Rounds a number to the xth decimal place (round( 3.14159265359, 4 ) --> 3.1416)
local function round( number, place )
	local pow = 10 ^ ( place or 0 )
    return math.floor( number * pow + .5 ) / pow
end

-- Gives the summation given a local function
local function getSummation( start, stop, func )
	local returnValues = {}
	local sum = 0
	for i = start, stop do
		local value = func( i, returnValues )
		returnValues[i] = value
		sum = sum + value
	end
	return sum
end

-- Gives the percent of change.
local function getPercentOfChange( old, new )
	if old == 0 and new == 0 then
        return 0
	else
		return ( new - old ) / math.abs( old )
	end
end

-- Gives the percentage of a number.
local function getPercentage( percent, number )
	return percent * number
end

-- Returns the quadratic roots of an equation.
local function getQuadraticRoots( a, b, c )
	local discriminant = b ^ 2 - ( 4 * a * c )
	if discriminant < 0 then return false end
	discriminant = math.sqrt( discriminant )
	local denominator = ( 2 * a )
	return ( -b - discriminant ) / denominator, ( -b + discriminant ) / denominator
end

-- Gives the angle between three points.
local function getAngle( x1, y1, x2, y2, x3, y3 )
    local a = getLength( x3, y3, x2, y2 )
    local b = getLength( x1, y1, x2, y2 )
    local c = getLength( x1, y1, x3, y3 )

   return math.acos( ( a * a + b * b - c * c ) / ( 2 * a * b ) )
end -- }}}

-- Circle --------------------------------------- {{{
-- Gives the area of the circle.
local function getCircleArea( radius )
	return math.pi * ( radius * radius )
end

-- Checks if a point is within the radius of a circle.
local function checkCirclePoint( x, y, circleX, circleY, radius )
	return getLength( circleX, circleY, x, y ) <= radius
end

-- Checks if a point is on a circle.
local function isPointOnCircle( x, y, circleX, circleY, radius )
	return checkFuzzy( getLength( circleX, circleY, x, y ), radius )
end

-- Gives the circumference of a circle.
local function getCircumference( radius )
	return 2 * math.pi * radius
end

-- Gives the intersection of a line and a circle.
local function getCircleLineIntersection( circleX, circleY, radius, x1, y1, x2, y2 )
	slope = getSlope( x1, y1, x2, y2 )
	intercept = getYIntercept( x1, y1, slope )

	if slope then
		local a = ( 1 + slope ^ 2 )
		local b = ( -2 * ( circleX ) + ( 2 * slope * intercept ) - ( 2 * circleY * slope ) )
		local c = ( circleX ^ 2 + intercept ^ 2 - 2 * ( circleY ) * ( intercept ) + circleY ^ 2 - radius ^ 2 )

		x1, x2 = getQuadraticRoots( a, b, c )

		if not x1 then return false end

		y1 = slope * x1 + intercept
		y2 = slope * x2 + intercept

		if checkFuzzy( x1, x2 ) and checkFuzzy( y1, y2 ) then
			return 'tangent', x1, y1
		else
			return 'secant', x1, y1, x2, y2
		end
	else -- Vertical Lines
		local lengthToPoint1 = circleX - x1
		local remainingDistance = lengthToPoint1 - radius
		local intercept = math.sqrt( -( lengthToPoint1 ^ 2 - radius ^ 2 ) )

		if -( lengthToPoint1 ^ 2 - radius ^ 2 ) < 0 then return false end

		local bottomX, bottomY = x1, circleY - intercept
		local topX, topY = x1, circleY + intercept

		if topY ~= bottomY then
			return 'secant', topX, topY, bottomX, bottomY
		else
			return 'tangent', topX, topY
		end
	end
end

-- Gives the type of intersection of a line segment.
local function getCircleSegmentIntersection( circleX, circleY, radius, x1, y1, x2, y2 )
	local Type, x3, y3, x4, y4 = getCircleLineIntersection( circleX, circleY, radius, x1, y1, x2, y2 )
	if not Type then return false end

	local slope, intercept = getSlope( x1, y1, x2, y2 ), getYIntercept( x1, y1, x2, y2 )

	if isPointOnCircle( x1, y1, circleX, circleY, radius ) and isPointOnCircle( x2, y2, circleX, circleY, radius ) then -- Both points are on line-segment.
		return 'chord', x1, y1, x2, y2
	end

	if slope then
		if checkCirclePoint( x1, y1, circleX, circleY, radius ) and checkCirclePoint( x2, y2, circleX, circleY, radius ) then -- Line-segment is fully in circle.
			return 'enclosed', x1, y1, x2, y2
		elseif x3 and x4 then
			if checkSegmentPoint( x3, y3, x1, y1, x2, y2 ) and not checkSegmentPoint( x4, y4, x1, y1, x2, y2 ) then -- Only the first of the points is on the line-segment.
				return 'tangent', x3, y3
			elseif checkSegmentPoint( x4, y4, x1, y1, x2, y2 ) and not checkSegmentPoint( x3, y3, x1, y1, x2, y2 ) then -- Only the second of the points is on the line-segment.
				return 'tangent', x4, y4
			else -- Neither of the points are on the circle (means that the segment is not on the circle, but "encasing" the circle)
				if checkSegmentPoint( x3, y3, x1, y1, x2, y2 ) and checkSegmentPoint( x4, y4, x1, y1, x2, y2 ) then
					return 'secant', x3, y3, x4, y4
				else
					return false
				end
			end
		elseif not x4 then -- Is a tangent.
			if checkSegmentPoint( x3, y3, x1, y1, x2, y2 ) then
				return 'tangent', x3, y3
			else -- Neither of the points are on the line-segment (means that the segment is not on the circle or "encasing" the circle).
				local length = getLength( x1, y1, x2, y2 )
				local distance1 = getLength( x1, y1, x3, y3 )
				local distance2 = getLength( x2, y2, x3, y3 )

				if length > distance1 or length > distance2 then
					return false
				elseif length < distance1 and length < distance2 then
					return false
				else
					return 'tangent', x3, y3
				end
			end
		end
	else
		local lengthToPoint1 = circleX - x1
		local remainingDistance = lengthToPoint1 - radius
		local intercept = math.sqrt( -( lengthToPoint1 ^ 2 - radius ^ 2 ) )

		if -( lengthToPoint1 ^ 2 - radius ^ 2 ) < 0 then return false end

		local topX, topY = x1, circleY - intercept
		local bottomX, bottomY = x1, circleY + intercept

		local length = getLength( x1, y1, x2, y2 )
		local distance1 = getLength( x1, y1, topX, topY )
		local distance2 = getLength( x2, y2, topX, topY )

		if bottomY ~= topY then -- Not a tangent
			if checkSegmentPoint( topX, topY, x1, y1, x2, y2 ) and checkSegmentPoint( bottomX, bottomY, x1, y1, x2, y2 ) then
				return 'chord', topX, topY, bottomX, bottomY
			elseif checkSegmentPoint( topX, topY, x1, y1, x2, y2 ) then
				return 'tangent', topX, topY
			elseif checkSegmentPoint( bottomX, bottomY, x1, y1, x2, y2 ) then
				return 'tangent', bottomX, bottomY
			else
				return false
			end
		else -- Tangent
			if checkSegmentPoint( topX, topY, x1, y1, x2, y2 ) then
				return 'tangent', topX, topY
			else
				return false
			end
		end
	end
end

-- Checks if one circle intersects another circle.
local function getCircleCircleIntersection( circle1x, circle1y, radius1, circle2x, circle2y, radius2 )
	local length = getLength( circle1x, circle1y, circle2x, circle2y )
	if length > radius1 + radius2 then return false end -- If the distance is greater than the two radii, they can't intersect.
	if checkFuzzy( length, 0 ) and checkFuzzy( radius1, radius2 ) then return 'equal' end
	if checkFuzzy( circle1x, circle2x ) and checkFuzzy( circle1y, circle2y ) then return 'collinear' end

	local a = ( radius1 * radius1 - radius2 * radius2 + length * length ) / ( 2 * length )
	local h = math.sqrt( radius1 * radius1 - a * a )

	local p2x = circle1x + a * ( circle2x - circle1x ) / length
	local p2y = circle1y + a * ( circle2y - circle1y ) / length
	local p3x = p2x + h * ( circle2y - circle1y ) / length
	local p3y = p2y - h * ( circle2x - circle1x ) / length
	local p4x = p2x - h * ( circle2y - circle1y ) / length
	local p4y = p2y + h * ( circle2x - circle1x ) / length

	if not validateNumber( p3x ) or not validateNumber( p3y ) or not validateNumber( p4x ) or not validateNumber( p4y ) then
		return 'inside'
	end

	if checkFuzzy( length, radius1 + radius2 ) or checkFuzzy( length, math.abs( radius1 - radius2 ) ) then return 'tangent', p3x, p3y end
	return 'intersection', p3x, p3y, p4x, p4y
end

-- Checks if circle1 is entirely inside of circle2.
local function isCircleCompletelyInsideCircle( circle1x, circle1y, circle1radius, circle2x, circle2y, circle2radius )
	if not checkCirclePoint( circle1x, circle1y, circle2x, circle2y, circle2radius ) then return false end
	local Type = getCircleCircleIntersection( circle2x, circle2y, circle2radius, circle1x, circle1y, circle1radius )
	if ( Type ~= 'tangent' and Type ~= 'collinear' and Type ~= 'inside' ) then return false end
	return true
end

-- Checks if a line-segment is entirely within a circle.
local function isSegmentCompletelyInsideCircle( circleX, circleY, circleRadius, x1, y1, x2, y2 )
	local Type = getCircleSegmentIntersection( circleX, circleY, circleRadius, x1, y1, x2, y2 )
	return Type == 'enclosed'
end -- }}}

-- Polygon -------------------------------------- {{{
-- Gives the signed area.
-- If the points are clockwise the number is negative, otherwise, it's positive.
local function getSignedPolygonArea( ... )
	local points = checkInput( ... )

	-- Shoelace formula (https://en.wikipedia.org/wiki/Shoelace_formula).
	points[#points + 1] = points[1]
	points[#points + 1] = points[2]

	return ( .5 * getSummation( 1, #points / 2,
		function( index )
			index = index * 2 - 1 -- Convert it to work properly.
			return ( ( points[index] * cycle( points, index + 3 ) ) - ( cycle( points, index + 2 ) * points[index + 1] ) )
		end
	) )
end

-- Simply returns the area of the polygon.
local function getPolygonArea( ... )
	return math.abs( getSignedPolygonArea( ... ) )
end

-- Gives the height of a triangle, given the base.
-- base, x1, y1, x2, y2, x3, y3, x4, y4
-- base, area
local function getTriangleHeight( base, ... )
	local input = checkInput( ... )
	local area

	if #input == 1 then area = input[1] -- Given area.
	else area = getPolygonArea( input ) end -- Given coordinates.

	return ( 2 * area ) / base, area
end

-- Gives the centroid of the polygon.
local function getCentroid( ... )
	local points = checkInput( ... )

	points[#points + 1] = points[1]
	points[#points + 1] = points[2]

	local area = getSignedPolygonArea( points ) -- Needs to be signed here in case points are counter-clockwise.

	-- This formula: https://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
	local centroidX = ( 1 / ( 6 * area ) ) * ( getSummation( 1, #points / 2,
		function( index )
			index = index * 2 - 1 -- Convert it to work properly.
			return ( ( points[index] + cycle( points, index + 2 ) ) * ( ( points[index] * cycle( points, index + 3 ) ) - ( cycle( points, index + 2 ) * points[index + 1] ) ) )
		end
	) )

	local centroidY = ( 1 / ( 6 * area ) ) * ( getSummation( 1, #points / 2,
		function( index )
			index = index * 2 - 1 -- Convert it to work properly.
			return ( ( points[index + 1] + cycle( points, index + 3 ) ) * ( ( points[index] * cycle( points, index + 3 ) ) - ( cycle( points, index + 2 ) * points[index + 1] ) ) )
		end
	) )

	return centroidX, centroidY
end

-- Returns whether or not a line intersects a polygon.
-- x1, y1, x2, y2, polygonPoints
local function getPolygonLineIntersection( x1, y1, x2, y2, ... )
	local input = checkInput( ... )
	local choices = {}

	local slope = getSlope( x1, y1, x2, y2 )
	local intercept = getYIntercept( x1, y1, slope )

	local x3, y3, x4, y4
	if slope then
		x3, x4 = 1, 2
		y3, y4 = slope * x3 + intercept, slope * x4 + intercept
	else
		x3, x4 = x1, x1
		y3, y4 = y1, y2
	end

	for i = 1, #input, 2 do
		local x1, y1, x2, y2 = getLineSegmentIntersection( input[i], input[i + 1], cycle( input, i + 2 ), cycle( input, i + 3 ), x3, y3, x4, y4 )
		if x1 and not x2 then choices[#choices + 1] = { x1, y1 }
		elseif x1 and x2 then choices[#choices + 1] = { x1, y1, x2, y2 } end
        -- No need to check 2-point sets since they only intersect each poly line once.
	end

	local final = removeDuplicatePairs( choices )
	return #final > 0 and final or false
end

-- Returns if the line segment intersects the polygon.
-- x1, y1, x2, y2, polygonPoints
local function getPolygonSegmentIntersection( x1, y1, x2, y2, ... )
	local input = checkInput( ... )
	local choices = {}

	for i = 1, #input, 2 do
		local x1, y1, x2, y2 = getSegmentSegmentIntersection( input[i], input[i + 1], cycle( input, i + 2 ), cycle( input, i + 3 ), x1, y1, x2, y2 )
		if x1 and not x2 then choices[#choices + 1] = { x1, y1 }
		elseif x2 then choices[#choices + 1] = { x1, y1, x2, y2 } end
	end

	local final = removeDuplicatePairs( choices )
	return #final > 0 and final or false
end

-- Checks if the point lies INSIDE the polygon not on the polygon.
local function checkPolygonPoint( px, py, ... )
	local points = { unpack( checkInput( ... ) ) } -- Make a new table, as to not edit values of previous.

	local greatest, least = getGreatestPoint( points, 0 )
	if not isWithinBounds( least, py, greatest ) then return false end
	greatest, least = getGreatestPoint( points )
	if not isWithinBounds( least, px, greatest ) then return false end

	local count = 0
	for i = 1, #points, 2 do
		if checkFuzzy( points[i + 1], py ) then
			points[i + 1] = py + .001 -- Handles vertices that lie on the point.
            -- Not exactly mathematically correct, but a lot easier.
		end
		if points[i + 3] and checkFuzzy( points[i + 3], py ) then
			points[i + 3] = py + .001 -- Do not need to worry about alternate case, since points[2] has already been done.
		end
		local x1, y1 = points[i], points[i + 1]
		local x2, y2 = points[i + 2] or points[1], points[i + 3] or points[2]

		if getSegmentSegmentIntersection( px, py, greatest, py, x1, y1, x2, y2 ) then
			count = count + 1
		end
	end

	return count and count % 2 ~= 0
end

-- Returns if the line segment is fully or partially inside.
-- x1, y1, x2, y2, polygonPoints
local function isSegmentInsidePolygon( x1, y1, x2, y2, ... )
	local input = checkInput( ... )

	local choices = getPolygonSegmentIntersection( x1, y1, x2, y2, input ) -- If it's partially enclosed that's all we need.
	if choices then return true end

	if checkPolygonPoint( x1, y1, input ) or checkPolygonPoint( x2, y2, input ) then return true end
	return false
end

-- Returns whether two polygons intersect.
local function getPolygonPolygonIntersection( polygon1, polygon2 )
	local choices = {}

	for index1 = 1, #polygon1, 2 do
		local intersections = getPolygonSegmentIntersection( polygon1[index1], polygon1[index1 + 1], cycle( polygon1, index1 + 2 ), cycle( polygon1, index1 + 3 ), polygon2 )
		if intersections then
			for index2 = 1, #intersections do
				choices[#choices + 1] = intersections[index2]
			end
		end
	end

	for index1 = 1, #polygon2, 2 do
		local intersections = getPolygonSegmentIntersection( polygon2[index1], polygon2[index1 + 1], cycle( polygon2, index1 + 2 ), cycle( polygon2, index1 + 3 ), polygon1 )
		if intersections then
			for index2 = 1, #intersections do
				choices[#choices + 1] = intersections[index2]
			end
		end
	end

	choices = removeDuplicatePairs( choices )
	for i = #choices, 1, -1 do
		if type( choices[i][1] ) == 'table' then -- Remove co-linear pairs.
			table.remove( choices, i )
		end
	end

	return #choices > 0 and choices
end

-- Returns whether the circle intersects the polygon.
-- x, y, radius, polygonPoints
local function getPolygonCircleIntersection( x, y, radius, ... )
	local input = checkInput( ... )
	local choices = {}

	for i = 1, #input, 2 do
		local Type, x1, y1, x2, y2 = getCircleSegmentIntersection( x, y, radius, input[i], input[i + 1], cycle( input, i + 2 ), cycle( input, i + 3 ) )
		if x2 then
			choices[#choices + 1] = { Type, x1, y1, x2, y2 }
		elseif x1 then choices[#choices + 1] = { Type, x1, y1 } end
	end

	local final = removeDuplicates4Points( choices )

	return #final > 0 and final
end

-- Returns whether the circle is inside the polygon.
-- x, y, radius, polygonPoints
local function isCircleInsidePolygon( x, y, radius, ... )
	local input = checkInput( ... )
	return checkPolygonPoint( x, y, input )
end

-- Returns whether the polygon is inside the polygon.
local function isPolygonInsidePolygon( polygon1, polygon2 )
	local bool = false
	for i = 1, #polygon2, 2 do
		local result = false
		result = isSegmentInsidePolygon( polygon2[i], polygon2[i + 1], cycle( polygon2, i + 2 ), cycle( polygon2, i + 3 ), polygon1 )
		if result then bool = true; break end
	end
	return bool
end

-- Checks if a segment is completely inside a polygon
local function isSegmentCompletelyInsidePolygon( x1, y1, x2, y2, ... )
	local polygon = checkInput( ... )
	if not checkPolygonPoint( x1, y1, polygon )
	or not checkPolygonPoint( x2, y2, polygon )
	or getPolygonSegmentIntersection( x1, y1, x2, y2, polygon ) then
		return false
	end
	return true
end

-- Checks if a polygon is completely inside another polygon
local function isPolygonCompletelyInsidePolygon( polygon1, polygon2 )
	for i = 1, #polygon1, 2 do
		local x1, y1 = polygon1[i], polygon1[i + 1]
		local x2, y2 = polygon1[i + 2] or polygon1[1], polygon1[i + 3] or polygon1[2]
		if not isSegmentCompletelyInsidePolygon( x1, y1, x2, y2, polygon2 ) then
			return false
		end
	end
	return true
end

-------------- Circle w/ Polygons --------------
-- Gets if a polygon is completely within a circle
-- circleX, circleY, circleRadius, polygonPoints
local function isPolygonCompletelyInsideCircle( circleX, circleY, circleRadius, ... )
	local input = checkInput( ... )
	local function isDistanceLess( px, py, x, y, circleRadius ) -- Faster, does not use math.sqrt
		local distanceX, distanceY = px - x, py - y
		return distanceX * distanceX + distanceY * distanceY < circleRadius * circleRadius -- Faster. For comparing distances only.
	end

	for i = 1, #input, 2 do
		if not checkCirclePoint( input[i], input[i + 1], circleX, circleY, circleRadius ) then return false end
	end
	return true
end

-- Checks if a circle is completely within a polygon
-- circleX, circleY, circleRadius, polygonPoints
local function isCircleCompletelyInsidePolygon( circleX, circleY, circleRadius, ... )
	local input = checkInput( ... )
	if not checkPolygonPoint( circleX, circleY, ... ) then return false end

	local rad2 = circleRadius * circleRadius

	for i = 1, #input, 2 do
		local x1, y1 = input[i], input[i + 1]
		local x2, y2 = input[i + 2] or input[1], input[i + 3] or input[2]
		if distance2( x1, y1, circleX, circleY ) <= rad2 then return false end
		if getCircleSegmentIntersection( circleX, circleY, circleRadius, x1, y1, x2, y2 ) then return false end
	end
	return true
end -- }}}

-- Statistics ----------------------------------- {{{
-- Gets the average of a list of points
-- points
local function getMean( ... )
	local input = checkInput( ... )

	mean = getSummation( 1, #input,
		function( i, t )
			return input[i]
		end
	) / #input

	return mean
end

local function getMedian( ... )
	local input = checkInput( ... )

	table.sort( input )

	local median
	if #input % 2 == 0 then -- If you have an even number of terms, you need to get the average of the middle 2.
		median = getMean( input[#input / 2], input[#input / 2 + 1] )
	else
		median = input[#input / 2 + .5]
	end

	return median
end

-- Gets the mode of a number.
local function getMode( ... )
	local input = checkInput( ... )

	table.sort( input )
	local sorted = {}
	for i = 1, #input do
		local value = input[i]
		sorted[value] = sorted[value] and sorted[value] + 1 or 1
	end

	local occurrences, least = 0, {}
	for i, value in pairs( sorted ) do
		if value > occurrences then
			least = { i }
			occurrences = value
		elseif value == occurrences then
			least[#least + 1] = i
		end
	end

	if #least >= 1 then return least, occurrences
	else return false end
end

-- Gets the range of the numbers.
local function getRange( ... )
	local input = checkInput( ... )
	local high, low = math.max( unpack( input ) ), math.min( unpack( input ) )
	return high - low
end

-- Gets the variance of a set of numbers.
local function getVariance( ... )
	local input = checkInput( ... )
	local mean = getMean( ... )
	local sum = 0
	for i = 1, #input do
		sum = sum + ( mean - input[i] ) * ( mean - input[i] )
	end
	return sum / #input
end

-- Gets the standard deviation of a set of numbers.
local function getStandardDeviation( ... )
	return math.sqrt( getVariance( ... ) )
end

-- Gets the central tendency of a set of numbers.
local function getCentralTendency( ... )
	local mode, occurrences = getMode( ... )
	return mode, occurrences, getMedian( ... ), getMean( ... )
end

-- Gets the variation ratio of a data set.
local function getVariationRatio( ... )
	local input = checkInput( ... )
	local numbers, times = getMode( ... )
	times = times * #numbers -- Account for bimodal data
	return 1 - ( times / #input )
end

-- Gets the measures of dispersion of a data set.
local function getDispersion( ... )
	return getVariationRatio( ... ), getRange( ... ), getStandardDeviation( ... )
end -- }}}

-- Vector 2 ------------------------------------- {{{
--[[
Vector2 Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

local function newVector(x, y)
	return {x = x or 0, y = y or 0}
end

local function isVector(a)
	return type(a.x) == "number" and type(a.y) == "number"
end

local function cloneVector(a)
	return newVector(a.x, a.y)
end

local function unpackVector(a)
	return a.x, a.y
end

local function toStringVector(a)
	return string.format("(%f,%f)", a.x, a.y)
end

local function invertVector(a)
	return newVector(-a.x, -a.y)
end

local function addVector(a, b)
	if type(a) == "table" and type(b) == "table" then
		return newVector(a.x+b.x, a.y+b.y)
	elseif type(a) == "table" and type(b) == "number" then
		return newVector(a.x+b, a.y+b)
	elseif type(a) == "number" and type(b) == "table" then
		return newVector(a+b.x, a+b.y)
	end
end

local function subVector(a, b)
	if type(a) == "table" and type(b) == "table" then
		return newVector(a.x-b.x, a.y-b.y)
	elseif type(a) == "table" and type(b) == "number" then
		return newVector(a.x-b, a.y-b)
	elseif type(a) == "number" and type(b) == "table" then
		return newVector(a-b.x, a-b.y)
	end
end

local function mulVector(a, b)
	if type(a) == "table" and type(b) == "table" then
		return newVector(a.x*b.x, a.y*b.y)
	elseif type(a) == "table" and type(b) == "number" then
		return newVector(a.x*b, a.y*b)
	elseif type(a) == "number" and type(b) == "table" then
		return newVector(a*b.x, a*b.y)
	end
end

local function divVector(a, b)
	if type(a) == "table" and type(b) == "table" then
		return newVector(a.x/b.x, a.y/b.y)
	elseif type(a) == "table" and type(b) == "number" then
		return newVector(a.x/b, a.y/b)
	elseif type(a) == "number" and type(b) == "table" then
		return newVector(a/b.x, a/b.y)
	end
end

local function eqVector(a, b)
	return a.x == b.x and a.y == b.y
end

local function ltVector(a, b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

local function leVector(a, b)
	return a.x <= b.x and a.y <= b.y
end

local function gtVector(a, b)
	return ltVector(b, a)
end

local function geVector(a, b)
	return leVector(b, a)
end

local function dotVector(a, b)
	return a.x*b.x + a.y*b.y
end

local function len2Vector(a)
	return a.x * a.x + a.y * a.y
end

local function lenVector(a)
	return sqrt(len2Vector(a))
end

local function dist2Vector(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return (dx * dx + dy * dy)
end

local function distVector(a, b)
	return sqrt(dis2Vector(a, b))
end

local function normalizeVector(a)
	local l = lenVector(a)

	if l > 0 then
		return newVector(a.x / l, a.y / l)
	else
		return newVector(a.x, a.y)
	end
end

local function rotateVector(a, phi)
	local c, s = cos(phi), sin(phi)
	return newVector(c * a.x - s * a.y, s * a.x + c * a.y)
end

local function perpendicularVector(a)
	return newVector(-a.y, a.x)
end

local function projectOnVector(a, b)
	local s = (a.x * b.x + a.y * b.y) / (b.x * b.x + b.y * b.y)
	return newVector(s * b.x, s * b.y)
end

local function mirrorOnVector(a, b)
	local s = 2 * (a.x * b.x + a.y * b.y) / (b.x * b.x + b.y * b.y)
	return newVector(s * b.x - a.x, s * b.y - a.y)
end

local function crossVector(a, b)
	return a.x * v.y - a.y * v.x
end

-- ref.: http://blog.signalsondisplay.com/?p=336
local function trimVector(a, maxLen)
	local s = maxLen * maxLen / len2Vector(a)
	s = (s > 1 and 1) or sqrt(s)
	return newVector(a.x * s, a.y * s)
end

local function angleToVector(a, b)
	if b then
		return atan2(a.y-b.y, a.x-b.x)
	end

	return atan2(a.y, a.x)
end

local function lerpVector(a, b, s)
	return a + s * (b - a)
end -- }}}

return {
	_VERSION = 'MLib 0.11.0',
	_DESCRIPTION = 'A math and shape-intersection detection library for Lua',
	_URL = 'https://github.com/davisdude/mlib',
	point = {
		rotate = rotatePoint,
		scale = scalePoint,
		polarToCartesian = polarToCartesian,
		cartesianToPolar = cartesianToPolar,
	},
	line = {
		getLength = getLength,
		getMidpoint = getMidpoint,
		getSlope = getSlope,
		getPerpendicularSlope = getPerpendicularSlope,
		getYIntercept = getYIntercept,
		getIntersection = getLineLineIntersection,
		getClosestPoint = getClosestPoint,
		getSegmentIntersection = getLineSegmentIntersection,
		checkPoint = checkLinePoint,

		-- Aliases
		getDistance = getLength,
		getCircleIntersection = getCircleLineIntersection,
		getPolygonIntersection = getPolygonLineIntersection,
		getLineIntersection = getLineLineIntersection,
	},
	segment = {
		checkPoint = checkSegmentPoint,
		getPerpendicularBisector = getPerpendicularBisector,
		getIntersection = getSegmentSegmentIntersection,

		-- Aliases
		getCircleIntersection = getCircleSegmentIntersection,
		getPolygonIntersection = getPolygonSegmentIntersection,
		getLineIntersection = getLineSegmentIntersection,
		getSegmentIntersection = getSegmentSegmentIntersection,
		isSegmentCompletelyInsideCircle = isSegmentCompletelyInsideCircle,
		isSegmentCompletelyInsidePolygon = isSegmentCompletelyInsidePolygon,
	},
	math = {
		getRoot = getRoot,
		isPrime = isPrime,
		round = round,
		getSummation =	getSummation,
		getPercentOfChange = getPercentOfChange,
		getPercentage = getPercentage,
		getQuadraticRoots = getQuadraticRoots,
		getAngle = getAngle,
	},
	circle = {
		getArea = getCircleArea,
		checkPoint = checkCirclePoint,
		isPointOnCircle = isPointOnCircle,
		getCircumference = getCircumference,
		getLineIntersection = getCircleLineIntersection,
		getSegmentIntersection = getCircleSegmentIntersection,
		getCircleIntersection = getCircleCircleIntersection,
		isCircleCompletelyInside = isCircleCompletelyInsideCircle,
		isPolygonCompletelyInside = isPolygonCompletelyInsideCircle,
		isSegmentCompletelyInside = isSegmentCompletelyInsideCircle,

		-- Aliases
		getPolygonIntersection = getPolygonCircleIntersection,
		isCircleInsidePolygon = isCircleInsidePolygon,
		isCircleCompletelyInsidePolygon = isCircleCompletelyInsidePolygon,
	},
	polygon = {
		getSignedArea = getSignedPolygonArea,
		getArea = getPolygonArea,
		getTriangleHeight = getTriangleHeight,
		getCentroid = getCentroid,
		getLineIntersection = getPolygonLineIntersection,
		getSegmentIntersection = getPolygonSegmentIntersection,
		checkPoint = checkPolygonPoint,
		isSegmentInside = isSegmentInsidePolygon,
		getPolygonIntersection = getPolygonPolygonIntersection,
		getCircleIntersection = getPolygonCircleIntersection,
		isCircleInside = isCircleInsidePolygon,
		isPolygonInside = isPolygonInsidePolygon,
		isCircleCompletelyInside = isCircleCompletelyInsidePolygon,
		isSegmentCompletelyInside = isSegmentCompletelyInsidePolygon,
		isPolygonCompletelyInside = isPolygonCompletelyInsidePolygon,

		-- Aliases
		isCircleCompletelyOver = isPolygonCompletelyInsideCircle,
	},
	statistics = {
		getMean = getMean,
		getMedian = getMedian,
		getMode = getMode,
		getRange = getRange,
		getVariance = getVariance,
		getStandardDeviation = getStandardDeviation,
		getCentralTendency = getCentralTendency,
		getVariationRatio = getVariationRatio,
		getDispersion = getDispersion,
	},
	vec2 = {
		new = newVector,
		isVector = isVector,
		clone = cloneVector,
		toString = toStringVector,
		invert = invertVector,
		add = addVector,
		sub = subVector,
		mul = mulVector,
		div = divVector,
		eq = eqVector,
		lt = ltVector,
		le = leVector,
		gt = gtVector,
		ge = geVector,
		dot = dotVector,
		len = lenVector,
		len2 = len2Vector,
		dist = distVector,
		dist2 = dist2Vector,
		normalize = normalizeVector,
		rotate = rotateVector,
		perpendicular = perpendicularVector,
		projectOn = projectOnVector,
		mirrorOn = mirrorOnVector,
		cross = crossVector,
		trim = trimVector,
		angleTo = angleToVector,
		lerp = lerpVector,

        -- Aliases
        copy = cloneVector,
        subtract = subtractVector, 
        multiply = mulVector,
        divide = divVector,
        equal = eqVector,
        lessThan = ltVector,
        lessThanOrEqualTo = leVector,
        greaterThan = gtVector,
        greaterThanOrEqualTo = geVector,
        dotProduct = dotVector,
        length = lenVector,
        length2 = len2Vector,
        distance = distVector,
        distance2 = dist2Vector,
	},
}
