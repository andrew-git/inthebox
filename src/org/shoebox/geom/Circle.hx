/**
*  HomeMade by shoe[box]
*
*  Redistribution and use in source and binary forms, with or without 
*  modification, are permitted provided that the following conditions are
*  met:
*
* Redistributions of source code must retain the above copyright notice, 
*   this list of conditions and the following disclaimer.
*  
* Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the 
*    documentation and/or other materials provided with the distribution.
*  
* Neither the name of shoe[box] nor the names of its 
* contributors may be used to endorse or promote products derived from 
* this software without specific prior written permission.
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
* IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package org.shoebox.geom;

import org.shoebox.core.BoxMath;
import org.shoebox.geom.FPoint;

/**
 * ...
 * @author shoe[box]
 */

class Circle{

	public var radius ( default , _setRadius ) : Float;
	public var center : FPoint;

	private var _fRadius2 : Float;

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public function new( fx : Float , fy : Float , fRadius : Float ) {
			center = { x : fx , y : fy };
			radius = fRadius;
		}
	
	// -------o public

		/**
		* Collision vs AABB
		* 
		* @public
		* @param 	vs : Test collision with ( AABB )
		* @return	collision position ( FPoint )
		*/
		inline public function vsAABB( vs : AABB ) : FPoint {
			
			var clone = { 
							x : BoxMath.clamp( center.x , vs.min.x , vs.max.x ), 
							y : BoxMath.clamp( center.y , vs.min.y , vs.max.y ) 
						};

			var diff = { 
							x : clone.x - center.x,
							y : clone.y - center.y
						};

			if( BoxMath.length( diff.x , diff.y ) > radius * radius )
				return null;

			diff.x += center.x;
			diff.y += center.y;
			return diff;
		}

		/**
		* Collision vs AABB without intersection point calculation
		* for quickier calculation if not needed
		* 
		* @public
		* @param 	vs : Test collision with ( AABB )
		* @return	collision or not ( Bool )
		*/
		public function vsAABB2( vs : AABB ) : Bool {
			var DX = BoxMath.clamp( center.x , vs.min.x , vs.max.x ) - center.x;	
			var DY = BoxMath.clamp( center.y , vs.min.y , vs.max.y ) - center.y;	
			return ( BoxMath.length( DX , DY ) < _fRadius2 );
		}

		/**
		* Collision with a line ( infinite line collision )
		* 
		* @public
		* @param 	A : Point on line A ( FPoint )
		* @param 	B : Point on line B ( FPoint )
		* @return	true if collision ( Bool )
		*/
		inline public function vsLine( A : FPoint , B : FPoint ) : Bool {

			var UX = B.x - A.x;
			var UY = B.y - A.y;
			
			var ACX = center.x - A.x;
			var ACY = center.y - A.y;

			var fNum = UX * ACY - UY * ACX;
			if ( fNum < 0 )
				fNum = -fNum;

			var fDem = Math.sqrt( UX * UX + UY * UY );
			var CI = fNum / fDem;
			return CI < radius;

		}

		/**
		* Check Intersection with a line ( infinite )
		* 
		* @public
		* @param  A : Point on line 1 ( FPoint )
		* @param  B : Point on line 2 ( FPoint )
		* @return intersection ( FPoint )
		*/
		public function intersectionVsLine( A : FPoint , B : FPoint ) : FPoint {
			
			var u  = { x : B.x - A.x , y : B.y - A.y };
			var AC = { x : center.x - A.x , y : center.y - A.y };

			var ti : Float = ( u.x * AC.x + u.y * AC.y ) / ( u.x * u.x + u.y * u.y );

			return { 
							x : A.x + ti * u.x,
							y : A.y + ti * u.y
						};
		}


		/**
		* Collision with a line segment
		* 
		* @public
		* @param 	A : Line segment point A ( FPoint )
		* @param 	B : Line segment point B ( FPoint )
		* @return	true if collision ( Bool )
		*/
		public function vsSeg( A : FPoint , B : FPoint ) : Bool {

			if ( !vsLine( A , B ) )
				return false;
		  
		  	var ABX = B.x - A.x;
			var ABY = B.y - A.y;
			
			var ACX = center.x - A.x;
			var ACY = center.y - A.y;

			var BCX = center.x - B.x;
			var BCY = center.y - B.y;
			
			var f1 = ABX * ACX + ABY * ACY; // Scalar
			var f2 = (-ABX) * BCX + (-ABY) * BCY; // Scalar
		
			if ( f1 >= 0 && f2 >= 0 )
				return true;

			return ( vsPoint( A.x , A.y ) || vsPoint( B.x , B.y ) );
	
		}

		/**
		* Test if point is contains in the circle radius
		* 
		* @public
		* @param 	fx : Point X position ( Float )
		* @param 	fy : Point Y position ( Float )
		* @return	true if collision ( Bool )
		*/
		public function vsPoint( fx : Float , fy : Float ) : Bool {
			var f = ( fx - center.x ) * ( fx - center.x ) + ( fy - center.y ) * ( fy - center.y );
			return ( f < _fRadius2 );			
		}

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public function vsCircle( c : Circle ) : FPoint {
			
			var fx = c.center.x - center.x;
			var fy = c.center.y - center.y;
			var rad = c.radius + radius;

			if ( BoxMath.length( fx , fy ) > rad * rad )
				return null;

			var res = { 
							x : ( c.center.x * radius + center.x * c.radius ) / ( radius + c.radius ),
							y : ( c.center.y * radius + center.y * c.radius ) / ( radius + c.radius )
						};
			return res;
		}

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public function vsCircle2( c : Circle ) : Bool {
			
			var fx = c.center.x - center.x;
			var fy = c.center.y - center.y;
			var rad = c.radius + radius;

			return BoxMath.length( fx , fy ) < rad * rad;

		}

	// -------o protected
		
		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private function _setRadius( f : Float ) : Float{
			_fRadius2 = f * f;
			return this.radius = f;
		}

	// -------o misc
	
}