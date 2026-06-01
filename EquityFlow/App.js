import React, { useState, useEffect } from "react";
import {
  SafeAreaView,
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  Modal,
  Image,
  StatusBar,
  TextInput,
} from "react-native";

import { FontAwesome5 } from "@expo/vector-icons";

/* ---------------- DATA ---------------- */

const creatorsData = [
  {
    id: "1",
    name: "@AstroAlice",
    platform: "YouTube",
    icon: "youtube",
    image: "https://images.unsplash.com/photo-1527980965255-d3b416303d12",
    share: "0.25%",
    worth: "$8,112",
    hype: "9.1",
    price: 120.382,
  },
  {
    id: "2",
    name: "@CosmicCooks",
    platform: "TikTok",
    icon: "tiktok",
    image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
    share: "0.21%",
    worth: "$5,442",
    hype: "8.7",
    price: 98.231,
  },
  {
    id: "3",
    name: "@InstaNova",
    platform: "Instagram",
    icon: "instagram",
    image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2",
    share: "0.18%",
    worth: "$6,980",
    hype: "9.3",
    price: 110.55,
  },
  {
    id: "4",
    name: "@FaceTrendz",
    platform: "Facebook",
    icon: "facebook",
    image: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde",
    share: "0.16%",
    worth: "$4,230",
    hype: "8.4",
    price: 88.12,
  },
];

/* ---------------- APP ---------------- */

export default function App() {
  const [activeTab, setActiveTab] = useState("Dashboard");
  const [portfolio, setPortfolio] = useState(32450.8);
  const [selectedCreator, setSelectedCreator] = useState(null);
  const [modalVisible, setModalVisible] = useState(false);
  const [search, setSearch] = useState("");

  useEffect(() => {
    const interval = setInterval(() => {
      setPortfolio((p) => +(p + Math.random() * 10).toFixed(2));
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const investCreator = (c) => {
    setSelectedCreator(c);
    setModalVisible(true);
  };

  /* ---------------- DASHBOARD ---------------- */

  const Dashboard = () => (
    <ScrollView>
      <View style={styles.header}>
        <Text style={styles.logo}>
          EQUITY<Text style={styles.logoBlue}>FLOW</Text>
        </Text>
        <Text style={styles.logoBlue}>Welcome back, Sankalpa 👋</Text>

        <Text style={styles.logoBlue}>Platinum Tier Investor🏆</Text>
      </View>

      <View style={styles.heroCard}>
        <Text style={styles.heroLabel}>PORTFOLIO VALUE</Text>
        <Text style={styles.heroAmount}>
          ${portfolio.toFixed(2)}
        </Text>
        <Text style={styles.growth}>▲ 12.5% 24h</Text>
      </View>

      <Text style={styles.sectionTitle}>Creators</Text>

      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        {creatorsData.map((c) => (
          <Pressable
            key={c.id}
            style={styles.card}
            onPress={() => investCreator(c)}
          >
            <Image source={{ uri: c.image }} style={styles.image} />

            <View style={styles.row}>
              <FontAwesome5 name={c.icon} size={14} color="#00E0FF" />
              <Text style={styles.name}>{c.name}</Text>
            </View>

            <Text style={styles.info}>Value: {c.worth}</Text>
          </Pressable>
        ))}
      </ScrollView>
    </ScrollView>
  );

  /* ---------------- DISCOVER ---------------- */

  const Discover = () => (
    <ScrollView>
      <Text style={styles.pageTitle}>Discover Creators</Text>

      <TextInput
        placeholder="Search creators..."
        placeholderTextColor="#94A3B8"
        value={search}
        onChangeText={setSearch}
        style={styles.search}
      />

      {creatorsData
        .filter((c) =>
          c.name.toLowerCase().includes(search.toLowerCase())
        )
        .map((c) => (
          <View key={c.id} style={styles.listItem}>
            <Image source={{ uri: c.image }} style={styles.smallImg} />
            <View>
              <Text style={styles.name}>{c.name}</Text>
              <Text style={styles.info}>{c.platform}</Text>
            </View>
          </View>
        ))}
    </ScrollView>
  );

  /* ---------------- WALLET ---------------- */

  const Wallet = () => (
    <View style={styles.center}>
      <Text style={styles.big}>$18,240.55</Text>
      <Text style={styles.info}>Total Earnings</Text>

      <View style={styles.walletBox}>
        <Text style={styles.walletText}>Available Balance</Text>
        <Text style={styles.walletAmount}>$6,120.20</Text>
      </View>

      <Pressable style={styles.btn}>
        <Text style={styles.btnText}>Withdraw Funds</Text>
      </Pressable>
    </View>
  );

  /* ---------------- MARKET ---------------- */

  const Market = () => (
    <ScrollView>
      <Text style={styles.pageTitle}>Market Overview</Text>

      <View style={styles.marketCard}>
        <Text style={styles.marketLabel}>Creator Index</Text>
        <Text style={styles.marketValue}>+3.42%</Text>
      </View>

      <View style={styles.marketCard}>
        <Text style={styles.marketLabel}>Tech Creators</Text>
        <Text style={styles.marketValue}>+1.87%</Text>
      </View>

      <View style={styles.marketCard}>
        <Text style={styles.marketLabel}>Lifestyle Creators</Text>
        <Text style={styles.marketValue}>-0.42%</Text>
      </View>
    </ScrollView>
  );

  /* ---------------- PROFILE ---------------- */

  const Profile = () => (
    <View style={styles.center}>
      <View style={styles.avatar} />
      <Text style={styles.big}>Sankalpa Budhathoki</Text>
      <Text style={styles.info}>Premium Investor</Text>

      <View style={styles.profileBox}>
        <Text style={styles.info}>📊 Portfolio Growth: +18%</Text>
        <Text style={styles.info}>🏆 Rank: Platinum</Text>
        <Text style={styles.info}>💼 Active Investments: 12</Text>
      </View>
    </View>
  );

  /* ---------------- ROUTER ---------------- */

  const renderScreen = () => {
    switch (activeTab) {
      case "Dashboard":
        return <Dashboard />;
      case "Discover":
        return <Discover />;
      case "Wallet":
        return <Wallet />;
      case "Market":
        return <Market />;
      case "Profile":
        return <Profile />;
    }
  };

  const NavItem = ({ icon, label }) => {
    const active = activeTab === label;

    return (
      <Pressable
        onPress={() => setActiveTab(label)}
        style={styles.navItem}
      >
        <FontAwesome5
          name={icon}
          size={18}
          color={active ? "#00E0FF" : "#94A3B8"}
        />
        <Text style={active ? styles.activeText : styles.navText}>
          {label}
        </Text>
      </Pressable>
    );
  };

  return (
    <SafeAreaView style={styles.safe}>
      <StatusBar barStyle="light-content" />

      <View style={{ flex: 1 }}>{renderScreen()}</View>

      {/* NAV */}
      <View style={styles.nav}>
        <NavItem icon="home" label="Dashboard" />
        <NavItem icon="search" label="Discover" />
        <NavItem icon="wallet" label="Wallet" />
        <NavItem icon="chart-line" label="Market" />
        <NavItem icon="user" label="Profile" />
      </View>

      {/* MODAL */}
      <Modal visible={modalVisible} transparent>
        <View style={styles.overlay}>
          <View style={styles.modal}>
            <Text style={styles.big}>{selectedCreator?.name}</Text>
            <Text style={styles.marketValue}>
              ${selectedCreator?.price?.toFixed(3)}
            </Text>

            <Pressable
              style={styles.btn}
              onPress={() => setModalVisible(false)}
            >
              <Text style={styles.btnText}>Invest Now</Text>
            </Pressable>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

/* ---------------- STYLES ---------------- */

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: "#050816" },

  header: { padding: 20 },

  logo: { color: "white", fontSize: 26, fontWeight: "800" },
  logoBlue: { color: "#00E0FF" },

  heroCard: {
    margin: 20,
    padding: 20,
    borderRadius: 20,
    backgroundColor: "#4C1D95",
  },

  heroLabel: { color: "#C4B5FD" },
  heroAmount: { color: "white", fontSize: 30, fontWeight: "800" },
  growth: { color: "#4ADE80", marginTop: 6 },

  sectionTitle: {
    color: "white",
    fontSize: 18,
    fontWeight: "800",
    marginLeft: 20,
  },

  card: {
    width: 220,
    margin: 10,
    padding: 12,
    backgroundColor: "#1E1B4B",
    borderRadius: 16,
  },

  image: { width: "100%", height: 110, borderRadius: 12 },

  row: { flexDirection: "row", alignItems: "center", marginTop: 8 },

  name: { color: "white", marginLeft: 6, fontWeight: "700" },

  info: { color: "#CBD5E1", marginTop: 4 },

  pageTitle: {
    color: "white",
    fontSize: 22,
    fontWeight: "800",
    margin: 20,
  },

  search: {
    margin: 20,
    padding: 12,
    borderRadius: 10,
    backgroundColor: "#111827",
    color: "white",
  },

  listItem: {
    flexDirection: "row",
    padding: 12,
    marginHorizontal: 20,
    backgroundColor: "#1E1B4B",
    marginBottom: 10,
    borderRadius: 12,
    alignItems: "center",
  },

  smallImg: { width: 50, height: 50, borderRadius: 10, marginRight: 10 },

  center: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },

  big: { color: "white", fontSize: 24, fontWeight: "800" },

  walletBox: {
    marginTop: 20,
    padding: 20,
    backgroundColor: "#1E1B4B",
    borderRadius: 16,
  },

  walletText: { color: "#94A3B8" },
  walletAmount: { color: "white", fontSize: 22 },

  btn: {
    marginTop: 20,
    backgroundColor: "#00E0FF",
    padding: 14,
    borderRadius: 12,
  },

  btnText: { fontWeight: "800", textAlign: "center" },

  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: "#1E1B4B",
    marginBottom: 12,
  },

  profileBox: {
    marginTop: 20,
    padding: 20,
    backgroundColor: "#1E1B4B",
    borderRadius: 16,
  },

  nav: {
    flexDirection: "row",
    justifyContent: "space-around",
    paddingVertical: 14,
    backgroundColor: "#020617",
  },

  navItem: { alignItems: "center" },

  navText: { color: "#94A3B8", fontSize: 11 },
  activeText: { color: "#00E0FF", fontSize: 11 },

  overlay: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.7)",
    justifyContent: "center",
    alignItems: "center",
  },

  modal: {
    width: "80%",
    backgroundColor: "#0F172A",
    padding: 20,
    borderRadius: 20,
  },

  marketCard: {
    margin: 15,
    padding: 20,
    backgroundColor: "#1E1B4B",
    borderRadius: 14,
  },

  marketLabel: { color: "#94A3B8" },
  marketValue: { color: "#4ADE80", fontSize: 18, fontWeight: "800" },
});