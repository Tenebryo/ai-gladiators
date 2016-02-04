/*
   Copyright 2016 Sam Blazes

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

class Projectile
{
  public int q, r, h, p;

  public Projectile(int qq, int rr, int hh, int pp)
  {
    q = qq;
    r = rr;
    h = hh;
    p = pp;
  }

  public void step()
  {
    int nq = q, nr = r;
    switch(h)
    {
    case 0: 
      nq++; 
      break;
    case 1:  
      nr++; 
      break;
    case 2: 
      nq--;
      nr++; 
      break;
    case 3: 
      nq--; 
      break;
    case 4: 
      nr--; 
      break;
    case 5: 
      nq++; 
      nr--; 
      break;
    }
    q = nq;
    r = nr;
  }

  public void draw(float interp)
  {
    pushMatrix();
    {
      stroke(0);
      fill(255, 100, 100);
      if (p == 1)
      {
        fill(100, 100, 255);
      }

      rotate(h*PI/3.0);
      translate(-40+40*interp,0);

      beginShape();
      {
        vertex(6, 1);
        vertex(7, 0);
        vertex(6, -1);
        vertex(-3, -1);
        vertex(-3, 1);
      }
      endShape(CLOSE);

      fill(255, 0, 0);

      beginShape();
      {
        vertex(-3, 0);
        vertex(-5, 3);
        vertex(-4, 2);
        vertex(-6, 0);
        vertex(-4, -2);
        vertex(-5, -3);
      }
      endShape(CLOSE);
    }
    popMatrix();
  }
}