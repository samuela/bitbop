import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import Heading from "@theme/Heading";
import Layout from "@theme/Layout";
import clsx from "clsx";

import Link from "@docusaurus/Link";
import styles from "./index.module.css";

// background-image: linear-gradient(45deg, #f3ec78, #af4261);
function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)}>
      <div className="container">
        <div className="row">
          <div className={clsx("col col--7")}>
            <Heading as="h1">
              Run{" "}
              <code className={clsx(styles.heroSSH)}>
                <span>ssh bitbop.io</span>
              </code>
              ,<br />
              get a GPU dev machine
              {/* 🤖 */}
            </Heading>
            <p
              className="hero__subtitle"
              style={{
                marginTop: "2rem",
                marginBottom: "2rem",
                textShadow: "1px 1px 80px rgb(255, 0, 255)",
              }}
            >
              <code
                style={{ background: "none", border: "none", opacity: 0.75 }}
              >
                {/* ❯_ dev machines for human beings */}
                ❯_ your personal workstation in the cloud
              </code>
            </p>
            {/* <div className={styles.buttons}>
              <Link
                className="button button--secondary button--lg"
                to="/docs/intro"
              >
                Docusaurus Tutorial - 5min ⏱️
              </Link>
            </div> */}
          </div>
          <div className={clsx("col col--5")} style={{ padding: 0 }}>
            <iframe
              style={{ borderRadius: "20px", overflow: "hidden" }}
              width="100%"
              height="300"
              src="https://www.youtube.com/embed/1BCWXFC7Scs?si=g-JX4p9ANVNNBgAe"
              title="YouTube video player"
              frameBorder="0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
              allowFullScreen
            />
          </div>
        </div>
      </div>
    </header>
  );
}

export default function Home(): JSX.Element {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description="Description will go into a meta tag in <head />"
    >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <hr />
        <section style={{ paddingTop: "5rem", paddingBottom: "5rem" }}>
          <div className="container">
            <Heading
              as="h1"
              style={{ fontSize: "2.5rem", paddingBottom: "1rem" }}
            >
              FAQs
            </Heading>
            <h2>What about long training runs? Can I prevent auto-shutdown?</h2>
            <p>
              Yes, you can prevent auto-shutdown behavior with{" "}
              <code>//keepalive</code>, eg with{" "}
              <code>ssh bitbop.io //keepalive 6h</code>. Once enabled, you can
              safely log off your instance and it will remain running at least
              as long as selected. Check out{" "}
              <Link to="/docs#keep-alive">the docs</Link> for more info!
            </p>
            <p>
              Async job support, including multi-machine jobs, is in
              development.
            </p>
            <h2>Can I use notebooks like Jupyter?</h2>
            <p>
              Yes, port forwarding is supported and Jupyter comes pre-installed,
              so you'll be all set up to run notebooks!
            </p>
            <h2>How do I transfer files to/from my bitbop.io machine?</h2>
            <p>
              You can transfer files with{" "}
              <a href="https://linux.die.net/man/1/scp">scp</a>,{" "}
              <a href="https://linux.die.net/man/1/rsync">rsync</a>,{" "}
              <a href="https://linux.die.net/man/1/sshfs">sshfs</a>, or good ol'
              drag-n-drop in VSCode.
            </p>
            <h2>What files are persisted?</h2>
            <p>
              The entirety of your root filesystem will be persisted, just as if
              you were working on a personal, physical machine. So everything in{" "}
              <code>/</code> will be retained. (Note however that this doesn't
              apply to <code>Free Trial</code> machines.)
            </p>
            <h2>
              I'm getting a <code>Permission denied (publickey)</code> error.
              What gives?
            </h2>
            <p>
              bitbop.io supports RSA and Ed25519 keys. Check for files{" "}
              <code>~/.ssh/id_rsa.pub</code>, <code>~/.ssh/id_ed25519.pub</code>
              , or similar. You'll need to have at least one keypair active and{" "}
              <a href="https://github.com/settings/keys">
                linked to your GitHub account
              </a>
              .
            </p>
          </div>
        </section>
        <hr />
        <section style={{ paddingTop: "5rem", paddingBottom: "5rem" }}>
          <div className="container">
            <Heading
              as="h1"
              style={{ fontSize: "2.5rem", paddingBottom: "1rem" }}
            >
              Pricing
            </Heading>
            <p>
              <strong>Working in academia?</strong>{" "}
              <a href="mailto:skainsworth+bitbop@gmail.com?subject=Academic discount">
                Contact us
              </a>{" "}
              for a discount.
            </p>
            <p>
              <strong>Support axSpA research.</strong> 5% of proceeds go to
              research on{" "}
              <a href="https://rheumatology.org/patients/spondyloarthritis">
                axial spondyloarthritis
              </a>{" "}
              (aka ankylosing spondylitis).
            </p>
            <div
              className="container"
              style={{ marginTop: "3rem", marginBottom: "3rem" }}
            >
              <div className="row">
                <div className="col col--4">
                  <div className={styles.pricingCard}>
                    <div className={styles.pricingCardHeader}>
                      <h2>Free trial</h2>
                      {/* <p>For experiencing </p> */}
                    </div>
                    <div className={styles.pricingCardBody}>
                      {/* <p className={styles.price} style={{ visibility: "hidden" }}>
                        <span className={styles.priceAmount}>$0</span>/month
                      </p> */}
                      <p className={styles.price}>
                        <span className={styles.priceAmount}>$0</span>/month
                      </p>
                      <ul>
                        <li>Try out bitbop.io for free!</li>
                        <li>
                          Temporary <code>2x-cpu</code> machines
                        </li>
                        <li>Filesystem is not persistent</li>
                      </ul>
                    </div>
                    {/* <div className={styles.pricingCardFooter}>
                      <a href="#" className="button button--disabled">
                        $ ssh bitbop.io
                      </a>
                    </div> */}
                  </div>
                </div>
                <div className="col col--4">
                  <div className={styles.pricingCard}>
                    <div className={styles.pricingCardHeader}>
                      <h2>Individual</h2>
                      {/* <p>For larger projects</p> */}
                    </div>
                    <div className={styles.pricingCardBody}>
                      <p className={styles.price}>
                        <span className={styles.priceAmount}>$19</span>/month
                      </p>
                      <ul>
                        <li>Persistent file system</li>
                        <li>
                          Unlimited <code>2x-cpu</code> usage
                        </li>
                        <li>CPU, T4, and V100 GPU machines</li>
                        <li>Community support</li>
                      </ul>
                    </div>
                    <div className={styles.pricingCardFooter}>
                      <a
                        href="mailto:skainsworth+bitbop@gmail.com?subject=Sign up for Individual account"
                        className="button button--primary"
                      >
                        Get started →
                      </a>
                    </div>
                  </div>
                </div>
                <div className="col col--4">
                  <div className={styles.pricingCard}>
                    <div className={styles.pricingCardHeader}>
                      <h2>Custom</h2>
                      {/* <p>For teams</p> */}
                    </div>
                    <div className={styles.pricingCardBody}>
                      <p style={{ opacity: 0.75 }}>
                        {/* Empty span to ensure that everything lines up with the other plans on the y axis. */}
                        <span className={styles.priceAmount}></span> ←
                        Everything in Individual, plus:
                      </p>
                      <ul>
                        <li>A100 and H100 GPU machines</li>
                        <li>On-prem deployment</li>
                        <li>Custom disk images</li>
                        <li>SAML/SSO integration</li>
                      </ul>
                    </div>
                    <div className={styles.pricingCardFooter}>
                      <a
                        href="mailto:skainsworth+bitbop@gmail.com?subject=Custom plan inquiry"
                        className="button button--secondary"
                        style={{ backgroundColor: "unset", color: "#ccc" }}
                      >
                        Contact sales →
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
