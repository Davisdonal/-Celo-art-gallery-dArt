import React from 'react';
import { useState } from "react";

export const Arts = (props) => {

  const [newtip, setNewtip] = useState('');



  return <div className="card-container">
   
   {props.arts.map((art) => (
      <div class="card">
         <h3>Arts</h3>
        <img class="card-img-top" src={art.image} alt="Card image cap" />
        <div class="card-body">
          <p class="card-text">{art.description}</p>
          <p class="card-title">Tip: {art.tip / 1000000000000000000}cUSD</p>
          {props.walletAddress !== art.owner && (
            <button type="button" onClick={() => props.tipArtist(art.index)} class="btn btn-dark mt-2">Tip Art</button>
          )
          }

        

          {props.walletAddress === art.owner && (
            <form>
              <div class="form-r">
                <input type="text" class="form-control mt-4" value={newtip}
                  onChange={(e) => setNewtip(e.target.value)} placeholder="new tip" />
                <button type="button" onClick={() => props.modifyTip(art.index, newtip)} class="btn btn-dark mt-2">Change Tip Amount</button>

              </div>
            </form>
          )}
        </div>
      </div>
    ))}

  </div>
};
