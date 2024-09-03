import { useState } from "react";
import "../../../App.css";
import { waveform } from "ldrs";

interface IProps {
  show: boolean;
}
waveform.register();
export const Loader = (props: IProps) => {
  const [showloader] = useState(props.show);

  return (
    <>
      {showloader === true ? (
        <div className="loading">
          <l-waveform
            size="50"
            stroke="3.5"
            speed="1.5"
            color="#40c057"
          ></l-waveform>

          <div className="loaderText">Buscando</div>
        </div>
      ) : (
        ""
      )}
    </>
  );
};
