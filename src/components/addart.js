import React from 'react';
import { useState } from "react";

export const AddArt = (props) => {

     const [image, setImage] = useState('');
     const [description, setDescription] = useState('');
     const [tip, setTip] = useState('');


     return <div>
          <form>
               <div class="form-row">
                    <h1> Add the art you want to Display</h1>

                    <input type="text" class="form-control" value={image}
                         onChange={(e) => setImage(e.target.value)} placeholder="image" />

                    <input type="text" class="form-control mt-2" value={description}
                         onChange={(e) => setDescription(e.target.value)} placeholder="description" />

                    <input type="text" class="form-control mt-2" value={tip}
                         onChange={(e) => setTip(e.target.value)} placeholder="tip" />


                    <button type="button" onClick={() => props.addArt(image, description, tip)} class="btn btn-dark mt-2">Add Art</button>
               </div>
          </form>
     </div>;
};
