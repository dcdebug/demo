import Script from "next/script";
//install next/script;
type Props = {
  pId: string;
};

const GoogleAdsense: React.FC<Props> = ({ pId }) => {
  //development.
  if (process.env.NODE_ENV !== "production") {
    return null;
  }
  return (
    <Script
      async
      src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-${pId}`}
      crossOrigin="anonymous"
      strategy="afterInteractive"
    />
  );
};

export default GoogleAdsense;
