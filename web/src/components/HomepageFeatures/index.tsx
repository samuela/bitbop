import Heading from "@theme/Heading";
import clsx from "clsx";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
  {
    // title: "Any GPU, any time",
    title: "Any GPU, any time 🦾",
    description: (
      <>
        Change your machine type at any moment. All your files will persist.
        Train your model on 8xH100s one minute, then switch to a CPU-only
        machine the next.
      </>
    ),
  },
  {
    // title: "Batteries included",
    title: "Batteries included 🔋",
    description: (
      <>
        We install and configure NVIDIA drivers, CUDA, JAX, PyTorch, and Nix so
        you don't have to. You're one SSH command away from a ready-to-go
        workstation.
      </>
    ),
  },
  {
    // title: "Sleep easy",
    title: "Sleep easy 😴",
    description: (
      <>
        bitbop.io automatically shuts down your machine when you're not using it
        so you don't get hit with a surprise bill. No more panic dreams about
        cloud bills.
      </>
    ),
  },
  // {
  //   title: "Support axSpA research 🔬",
  //   description: (
  //     <>
  //       5% of proceeds go to research on{" "}
  //       <a href="https://rheumatology.org/patients/spondyloarthritis">
  //         spondyloarthritis
  //       </a>{" "}
  //       (aka ankylosing spondylitis).
  //     </>
  //   ),
  // },
];

function Feature({ title, description }: FeatureItem) {
  return (
    <div className={clsx("col col--4", styles.feature)}>
      <div
        style={{
          borderWidth: "1px",
          borderColor: "#af7142",
          borderStyle: "dashed",
          borderRadius: "10px",
          paddingTop: "2rem",
          paddingLeft: "2rem",
          paddingRight: "2rem",
          paddingBottom: "2rem",
          height: "100%",
        }}
      >
        <Heading as="h3">{title}</Heading>
        <p style={{ opacity: 0.75, marginBottom: 0 }}>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
